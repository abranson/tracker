noinst_LTLIBRARIES = libtracker-sparql.la

libtracker_sparql_la_VALAFLAGS =                       \
	--gir Tracker-$(TRACKER_API_VERSION).gir       \
	--library tracker-sparql-$(TRACKER_API_VERSION) \
	--includedir=libtracker-sparql                 \
	--header $(vala_header:.h=-no-checks.h)        \
	--vapi tracker-sparql.vapi                     \
	--pkg gio-2.0 --pkg gmodule-2.0 --pkg posix    \
	$(BUILD_VALAFLAGS)

AM_CPPFLAGS =                                          \
	$(BUILD_VALACFLAGS)                            \
	-I$(top_srcdir)/src                            \
	-I$(top_builddir)/src                          \
	$(LIBTRACKER_SPARQL_CFLAGS)

libtracker_sparqlincludedir = $(includedir)/tracker-$(TRACKER_API_VERSION)/libtracker-sparql

libtracker_sparql_la_SOURCES =   \
	tracker-namespace.vala                         \
	tracker-builder.vala                           \
	tracker-connection.vala                        \
	tracker-cursor.vala                            \
	tracker-namespace-manager.c                    \
	tracker-namespace-manager.h                    \
	tracker-resource.c                             \
	tracker-resource.h                             \
	tracker-utils.vala                             \
	tracker-uri.c                                  \
	tracker-uri.h                                  \
	tracker-ontologies.h \
	tracker-version.c \
	tracker-version.h

libtracker_sparql_la_LIBADD =    \
	$(BUILD_LIBS)                                  \
	$(LIBTRACKER_SPARQL_LIBS)

# Should only be one file
vala_header = tracker-generated.h

# We wrap the generated .h file with a check to make sure it's
# not included directly. All other .[ch] headers have this.
%-generated.h: %-generated-no-checks.h
	$(AM_V_GEN)(echo "#if !defined (__LIBTRACKER_SPARQL_INSIDE__) && !defined (TRACKER_COMPILATION)" ; \
	            echo "#error \"only <libtracker-sparql/tracker-sparql.h> must be included directly.\"" ; \
	            echo "#endif") > $@
	$(AM_V_GEN)(cat $< >> $@)

tracker-sparql-$(TRACKER_API_VERSION).vapi: tracker-sparql.vapi
	$(AM_V_GEN)(sed -e 's/tracker-generated-no-checks.h/tracker-sparql.h/' $< > $@)

libtracker_sparqlinclude_HEADERS =                     \
	$(vala_header)                                 \
	tracker-namespace-manager.h                    \
	tracker-ontologies.h \
	tracker-resource.h                             \
	tracker-sparql.h                               \
	tracker-version.h

tracker-sparql-$(TRACKER_API_VERSION).deps: tracker-sparql.deps
	$(AM_V_GEN)cp $^ $@

# PkgConfig
pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = tracker-sparql-$(TRACKER_API_VERSION).pc

tracker-sparql-$(TRACKER_API_VERSION).pc: tracker-sparql.pc
	cp $< $@

CLEANFILES = tracker-sparql-$(TRACKER_API_VERSION).pc

# Vala bindings
vapidir = $(datadir)/vala/vapi
vapi_DATA =                                            \
	tracker-sparql-$(TRACKER_API_VERSION).vapi     \
	tracker-sparql-$(TRACKER_API_VERSION).deps

BUILT_SOURCES =                                        \
	libtracker_sparql_la_vala.stamp

MAINTAINERCLEANFILES =                                 \
	tracker-sparql-$(TRACKER_API_VERSION).vapi     \
	tracker-sparql-$(TRACKER_API_VERSION).deps     \
	$(vala_header:.h=-no-checks.h)

CLEANFILES += tracker-sparql-$(TRACKER_API_VERSION).vapi

EXTRA_DIST =                                           \
	tracker-sparql-$(TRACKER_API_VERSION).deps     \
	tracker-sparql.deps                            \
	$(vala_header:.h=-no-checks.h)

# Introspection foo
-include $(INTROSPECTION_MAKEFILE)

if HAVE_INTROSPECTION
Tracker-@TRACKER_API_VERSION@.typelib: Tracker-$(TRACKER_API_VERSION).gir
	@INTROSPECTION_COMPILER@ --shared-library=libtracker-sparql-@TRACKER_API_VERSION@.so.0 -o $@ $^

girdir = $(datadir)/gir-1.0
gir_DATA = Tracker-$(TRACKER_API_VERSION).gir

typelibdir = $(libdir)/girepository-1.0
typelib_DATA = $(gir_DATA:.gir=.typelib)

# We don't clean the gir/typelib data for *Vala* generated g-ir files.
# However, we do for *C* generated g-ir files due to Vala not being
# required when building from a tarball.
DISTCLEANFILES = $(gir_DATA) $(typelib_DATA)
endif
