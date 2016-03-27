# Experimental, incomplete build instructions for Tracker using
# Meson: http://www.mesonbuild.com/
#
# Note that I don't really like this Python-like DSL and would much
# rather represent the build instructions as YAML. That's a future
# project though which requires changes to Meson.

project('tracker', 'c', version: '1.8.0')

# 3.6.11 for sqlite_backup API
# 3.6.16 to fix test failures
# 3.6.17 for shared cache mode with virtual tables
# 3.7.0 for WAL
# 3.7.9 for FTS4 content= support
sqlite = dependency('sqlite3', version: '> 3.7.9')

cairo = dependency('cairo', version: '> 1.0')
camel = dependency('camel-1.2', version: '> 2.32.0', required: false)
dbus = dependency('dbus-1', version: '> 1.3.1')
eds = dependency('evolution-data-server-1.2', version: '> 2.32.0', required: false)
evo_plugin = dependency('evolution-shell-3.1', required: false)
evo_shell = dependency('evolution-shell-3.0', version: '> 3.1', required: false)
exempi = dependency('exempi-2.0', version: '> 2.1.0', required: false)
flac = dependency('flac', version: '> 1.2.1', required: false)
gee = dependency('gee-0.8', version: '> 0.3')
gio_unix = dependency('gio-unix-2.0', version: '> 2.40.0')
glib = dependency('glib-2.0', version: '> 2.40.0')
gstreamer = dependency('gstreamer-1.0', version: '> 0.10.31', required: false)
gstreamer_tag = dependency('gstreamer-tag-1.0', version: '> 0.10.31', required: false)
gtk3 = dependency('gtk+-3.0', version: '> 3.0.0', required: false)
gupnp_dlna = dependency('gupnp-dlna-2.0', version: '> 0.9.4', required: false)
hal = dependency('hal', version: '> 0.5', required: false)
libemail_utils = dependency('libemail-utils', required: false)
libemail_engine = dependency('libemail-engine', required: false)
libexif = dependency('libexif', version: '> 0.6', required: false)
libgrss = dependency('libgrss', version: '> 0.7', required: false)
libgsf = dependency('libgsf-1', version: '> 1.14.24', required: false)
libicu = dependency('libicu', version: '> 4.8.1.1', required: false)
libmediaart = dependency('libmediaart', version: '> 1.9.0', required: false)
libosinfo = dependency('libosinfo', version: '> 0.2.9', required: false)
libpng = dependency('libpng', version: '> 0.89', required: false)
libtiff = dependency('libtiff-4', required: false)
libxml2 = dependency('libxml-2.0', version: '> 2.6')
libvorbis = dependency('vorbisfile', version: '> 0.22')
meegotouch = dependency('meegotouch', version: '> 0.20', required: false)
network_manager = dependency('libnm-glib', version: '> 0.8', required: false)
poppler = dependency('poppler-glib', version: '> 0.16.0', required: false)
taglib = dependency('taglib_c', version: '> 1.6', required: false)
uuid = dependency('uuid')
upower = dependency('libupower-glib', version: '> 0.9.0', required: false)

zlib = dependency('zlib')

# FIXME: libgif doesn't have a pkg-config file, how do we deal with that?
libgif = dependency('libgif', required: false)

# FIXME: libjpeg doesn't have a pkg-config file, how do we deal with that?
libjpeg = dependency('libjpeg', required: false)

conf = configuration_data()
conf.set('PACKAGE_VERSION', meson.project_version())
configure_file(input: 'config.h.meson.in',
               output: 'config.h',
               configuration: conf)

executable(
    'tracker-needle',
    'src/tracker-needle/tracker-needle.c',
    dependencies: gtk3)
