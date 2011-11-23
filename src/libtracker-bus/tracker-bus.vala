/*
 * Copyright (C) 2010, Nokia <ivan.frade@nokia.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA  02110-1301, USA.
 */

public class Tracker.Bus.Connection : Tracker.Sparql.Connection {
	public Connection () throws Sparql.Error, IOError, DBusError {
		// ensure that error domain is registered with GDBus
		new Sparql.Error.INTERNAL ("");
	}

	void pipe (out UnixInputStream input, out UnixOutputStream output) throws IOError {
		int pipefd[2];
		if (Posix.pipe (pipefd) < 0) {
			throw new IOError.FAILED ("Pipe creation failed");
		}
		input = new UnixInputStream (pipefd[0], true);
		output = new UnixOutputStream (pipefd[1], true);
	}

	void handle_error_reply (DBusMessage message) throws Sparql.Error, IOError, DBusError {
		try {
			message.to_gerror ();
		} catch (IOError e_io) {
			throw e_io;
		} catch (Sparql.Error e_sparql) {
			throw e_sparql;
		} catch (DBusError e_dbus) {
			throw e_dbus;
		} catch (Error e) {
			throw new IOError.FAILED (e.message);
		}
	}

	void send_query (DBusConnection connection, string sparql, UnixOutputStream output, Cancellable? cancellable, AsyncReadyCallback? callback) throws GLib.IOError {
		var message = new DBusMessage.method_call (TRACKER_DBUS_SERVICE, TRACKER_DBUS_OBJECT_STEROIDS, TRACKER_DBUS_INTERFACE_STEROIDS, "Query");
		var fd_list = new UnixFDList ();
		message.set_body (new Variant ("(sh)", sparql, fd_list.append (output.fd)));
		message.set_unix_fd_list (fd_list);

		connection.send_message_with_reply.begin (message, DBusSendMessageFlags.NONE, int.MAX, null, cancellable, callback);
	}

	public override Sparql.Cursor query (string sparql, Cancellable? cancellable) throws Sparql.Error, IOError, DBusError {
		// use separate main context for sync operation
		var context = new MainContext ();
		var loop = new MainLoop (context, false);
		context.push_thread_default ();
		AsyncResult async_res = null;
		query_async.begin (sparql, cancellable, (o, res) => {
			async_res = res;
			loop.quit ();
		});
		loop.run ();
		context.pop_thread_default ();
		return query_async.end (async_res);
	}

	public async override Sparql.Cursor query_async (string sparql, Cancellable? cancellable = null) throws Sparql.Error, IOError, DBusError {
		UnixInputStream input;
		UnixOutputStream output;
		pipe (out input, out output);

		var connection = GLib.Bus.get_sync (BusType.SESSION, cancellable);

		// send D-Bus request
		AsyncResult dbus_res = null;
		bool received_result = false;
		send_query (connection, sparql, output, cancellable, (o, res) => {
			dbus_res = res;
			if (received_result) {
				query_async.callback ();
			}
		});

		output = null;

		// receive query results via FD
		var mem_stream = new MemoryOutputStream (null, GLib.realloc, GLib.free);
		yield mem_stream.splice_async (input, OutputStreamSpliceFlags.CLOSE_SOURCE | OutputStreamSpliceFlags.CLOSE_TARGET, Priority.DEFAULT, cancellable);

		// wait for D-Bus reply
		received_result = true;
		if (dbus_res == null) {
			yield;
		}

		var reply = connection.send_message_with_reply.end (dbus_res);
		handle_error_reply (reply);

		string[] variable_names = (string[]) reply.get_body ().get_child_value (0);
		mem_stream.close ();
		return new FDCursor (mem_stream.steal_data (), mem_stream.data_size, variable_names);
	}

	void send_update (DBusConnection connection, string method, UnixInputStream input, Cancellable? cancellable, AsyncReadyCallback? callback) throws GLib.IOError {
		var message = new DBusMessage.method_call (TRACKER_DBUS_SERVICE, TRACKER_DBUS_OBJECT_STEROIDS, TRACKER_DBUS_INTERFACE_STEROIDS, method);
		var fd_list = new UnixFDList ();
		message.set_body (new Variant ("(h)", fd_list.append (input.fd)));
		message.set_unix_fd_list (fd_list);

		connection.send_message_with_reply.begin (message, DBusSendMessageFlags.NONE, int.MAX, null, cancellable, callback);
	}

	public override void update (string sparql, int priority = GLib.Priority.DEFAULT, Cancellable? cancellable = null) throws Sparql.Error, IOError, DBusError {
		// use separate main context for sync operation
		var context = new MainContext ();
		var loop = new MainLoop (context, false);
		context.push_thread_default ();
		AsyncResult async_res = null;
		update_async.begin (sparql, priority, cancellable, (o, res) => {
			async_res = res;
			loop.quit ();
		});
		loop.run ();
		context.pop_thread_default ();
		update_async.end (async_res);
	}

	public async override void update_async (string sparql, int priority = GLib.Priority.DEFAULT, Cancellable? cancellable = null) throws Sparql.Error, IOError, DBusError {
		UnixInputStream input;
		UnixOutputStream output;
		pipe (out input, out output);

		var connection = GLib.Bus.get_sync (BusType.SESSION, cancellable);

		// send D-Bus request
		AsyncResult dbus_res = null;
		bool sent_update = false;
		send_update (connection, priority <= GLib.Priority.DEFAULT ? "Update" : "BatchUpdate", input, cancellable, (o, res) => {
			dbus_res = res;
			if (sent_update) {
				update_async.callback ();
			}
		});

		// send sparql string via fd
		var data_stream = new DataOutputStream (output);
		data_stream.set_byte_order (DataStreamByteOrder.HOST_ENDIAN);
		data_stream.put_int32 ((int32) sparql.length);
		data_stream.put_string (sparql);
		data_stream = null;

		// wait for D-Bus reply
		sent_update = true;
		if (dbus_res == null) {
			yield;
		}

		var reply = connection.send_message_with_reply.end (dbus_res);
		handle_error_reply (reply);
	}

	public async override GenericArray<Error?>? update_array_async (string[] sparql, int priority = GLib.Priority.DEFAULT, Cancellable? cancellable = null) throws Sparql.Error, IOError, DBusError {
		UnixInputStream input;
		UnixOutputStream output;
		pipe (out input, out output);

		var connection = GLib.Bus.get_sync (BusType.SESSION, cancellable);

		// send D-Bus request
		AsyncResult dbus_res = null;
		bool sent_update = false;
		send_update (connection, "UpdateArray", input, cancellable, (o, res) => {
			dbus_res = res;
			if (sent_update) {
				update_array_async.callback ();
			}
		});

		// send sparql strings via fd
		var data_stream = new DataOutputStream (output);
		data_stream.set_byte_order (DataStreamByteOrder.HOST_ENDIAN);
		data_stream.put_int32 ((int32) sparql.length);
		for (int i = 0; i < sparql.length; i++) {
			data_stream.put_int32 ((int32) sparql[i].length);
			data_stream.put_string (sparql[i]);
		}
		data_stream = null;

		// wait for D-Bus reply
		sent_update = true;
		if (dbus_res == null) {
			yield;
		}

		var reply = connection.send_message_with_reply.end (dbus_res);
		handle_error_reply (reply);

		// process results (errors)
		var result = new GenericArray<Error?> ();
		Variant resultv;
		resultv = reply.get_body ().get_child_value (0);
		var iter = resultv.iterator ();
		string code, message;
		while (iter.next ("s", out code)) {
			if (iter.next ("s", out message)) {
				if (code != "" && message != "") {
					result.add (new Sparql.Error.INTERNAL (message));
				} else {
					result.add (null);
				}

                                message = null;
			}

                        code = null;
		}
		return result;
	}

	public override GLib.Variant? update_blank (string sparql, int priority = GLib.Priority.DEFAULT, Cancellable? cancellable = null) throws Sparql.Error, IOError, DBusError {
		// use separate main context for sync operation
		var context = new MainContext ();
		var loop = new MainLoop (context, false);
		context.push_thread_default ();
		AsyncResult async_res = null;
		update_blank_async.begin (sparql, priority, cancellable, (o, res) => {
			async_res = res;
			loop.quit ();
		});
		loop.run ();
		context.pop_thread_default ();
		return update_blank_async.end (async_res);
	}

	public async override GLib.Variant? update_blank_async (string sparql, int priority = GLib.Priority.DEFAULT, Cancellable? cancellable = null) throws Sparql.Error, IOError, DBusError {
		UnixInputStream input;
		UnixOutputStream output;
		pipe (out input, out output);

		var connection = GLib.Bus.get_sync (BusType.SESSION, cancellable);

		// send D-Bus request
		AsyncResult dbus_res = null;
		bool sent_update = false;
		send_update (connection, "UpdateBlank", input, cancellable, (o, res) => {
			dbus_res = res;
			if (sent_update) {
				update_blank_async.callback ();
			}
		});

		// send sparql strings via fd
		var data_stream = new DataOutputStream (output);
		data_stream.set_byte_order (DataStreamByteOrder.HOST_ENDIAN);
		data_stream.put_int32 ((int32) sparql.length);
		data_stream.put_string (sparql);
		data_stream = null;

		// wait for D-Bus reply
		sent_update = true;
		if (dbus_res == null) {
			yield;
		}

		var reply = connection.send_message_with_reply.end (dbus_res);
		handle_error_reply (reply);
		return reply.get_body ().get_child_value (0);
	}

	public override void load (File file, Cancellable? cancellable = null) throws Sparql.Error, IOError, DBusError {
		var connection = GLib.Bus.get_sync (BusType.SESSION, cancellable);

		var message = new DBusMessage.method_call (TRACKER_DBUS_SERVICE, TRACKER_DBUS_OBJECT_RESOURCES, TRACKER_DBUS_INTERFACE_RESOURCES, "Load");
		message.set_body (new Variant ("(s)", file.get_uri ()));

		var reply = connection.send_message_with_reply_sync (message, DBusSendMessageFlags.NONE, int.MAX, null, cancellable);
		handle_error_reply (reply);
	}

	public async override void load_async (File file, Cancellable? cancellable = null) throws Sparql.Error, IOError, DBusError {
		var connection = GLib.Bus.get_sync (BusType.SESSION, cancellable);

		var message = new DBusMessage.method_call (TRACKER_DBUS_SERVICE, TRACKER_DBUS_OBJECT_RESOURCES, TRACKER_DBUS_INTERFACE_RESOURCES, "Load");
		message.set_body (new Variant ("(s)", file.get_uri ()));

		var reply = yield connection.send_message_with_reply (message, DBusSendMessageFlags.NONE, int.MAX, null, cancellable);
		handle_error_reply (reply);
	}

	public override Sparql.Cursor? statistics (Cancellable? cancellable = null) throws Sparql.Error, IOError, DBusError {
		var connection = GLib.Bus.get_sync (BusType.SESSION, cancellable);

		var message = new DBusMessage.method_call (TRACKER_DBUS_SERVICE, TRACKER_DBUS_OBJECT_STATISTICS, TRACKER_DBUS_INTERFACE_STATISTICS, "Get");

		var reply = connection.send_message_with_reply_sync (message, DBusSendMessageFlags.NONE, int.MAX, null, cancellable);
		handle_error_reply (reply);

		string[,] results = (string[,]) reply.get_body ().get_child_value (0);
		Sparql.ValueType[] types = new Sparql.ValueType[2];
		string[] var_names = new string[2];

		var_names[0] = "class";
		var_names[1] = "count";
		types[0] = Sparql.ValueType.STRING;
		types[1] = Sparql.ValueType.INTEGER;

		return new Tracker.Bus.ArrayCursor ((owned) results,
		                                    results.length[0],
		                                    results.length[1],
		                                    var_names,
		                                    types);
	}

	public async override Sparql.Cursor? statistics_async (Cancellable? cancellable = null) throws Sparql.Error, IOError, DBusError {
		var connection = GLib.Bus.get_sync (BusType.SESSION, cancellable);

		var message = new DBusMessage.method_call (TRACKER_DBUS_SERVICE, TRACKER_DBUS_OBJECT_STATISTICS, TRACKER_DBUS_INTERFACE_STATISTICS, "Get");

		var reply = yield connection.send_message_with_reply (message, DBusSendMessageFlags.NONE, int.MAX, null, cancellable);
		handle_error_reply (reply);

		string[,] results = (string[,]) reply.get_body ().get_child_value (0);
		Sparql.ValueType[] types = new Sparql.ValueType[2];
		string[] var_names = new string[2];

		var_names[0] = "class";
		var_names[1] = "count";
		types[0] = Sparql.ValueType.STRING;
		types[1] = Sparql.ValueType.INTEGER;

		return new Tracker.Bus.ArrayCursor ((owned) results,
		                                    results.length[0],
		                                    results.length[1],
		                                    var_names,
		                                    types);
	}
}
