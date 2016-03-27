# Experimental, incomplete build instructions for Tracker using
# Meson: http://www.mesonbuild.com/

project('tracker', 'c', 'vala', version: '1.8.0')

# This is the X.Y used in -llibtracker-FOO-X.Y
tracker_api_version = '1.0'

glib_required = '2.40.0'

# 3.6.11 for sqlite_backup API
# 3.6.16 to fix test failures
# 3.6.17 for shared cache mode with virtual tables
# 3.7.0 for WAL
# 3.7.9 for FTS4 content= support
sqlite_required = '3.7.9'

cairo = dependency('cairo', version: '> 1.0')
camel = dependency('camel-1.2', version: '> 2.32.0', required: false)
dbus = dependency('dbus-1', version: '> 1.3.1')
eds = dependency('evolution-data-server-1.2', version: '> 2.32.0', required: false)
evo_plugin = dependency('evolution-shell-3.1', required: false)
evo_shell = dependency('evolution-shell-3.0', version: '> 3.1', required: false)
exempi = dependency('exempi-2.0', version: '> 2.1.0', required: false)
flac = dependency('flac', version: '> 1.2.1', required: false)
gee = dependency('gee-0.8', version: '> 0.3')
gio = dependency('gio-2.0', version: '>' + glib_required)
gio_unix = dependency('gio-unix-2.0', version: '>' + glib_required)
glib = dependency('glib-2.0', version: '>' + glib_required)
gobject = dependency('gobject-2.0', version: '>' + glib_required)
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
sqlite = dependency('sqlite3', version: '>' + sqlite_required)
taglib = dependency('taglib_c', version: '> 1.6', required: false)
uuid = dependency('uuid')
upower = dependency('libupower-glib', version: '> 0.9.0', required: false)
zlib = dependency('zlib')

# These two don't have pkg-config files.
libgif = meson.get_compiler('c').find_library('libgif', required: false)
libjpeg = meson.get_compiler('c').find_library('libjpeg', required: false)

conf = configuration_data()
conf.set('GETTEXT_PACKAGE', 'tracker')
conf.set('HAVE_LIBMEDIAART', libmediaart.found())
conf.set('LOCALEDIR', get_option('localedir'))
conf.set('PACKAGE_VERSION', meson.project_version())
conf.set('TRACKER_UI_DIR', get_option('datadir') + '/tracker/')
configure_file(input: 'config.h.meson.in',
               output: 'config.h',
               configuration: conf)

gettext('tracker', languages:
    ['ar', 'as', 'be@latin', 'bg', 'bs', 'ca', 'ca@valencia', 'cs', 'da', 'de',
     'dz', 'el', 'en_GB', 'eo', 'es', 'et', 'eu', 'fi', 'fr', 'gl', 'he', 'hu',
     'id', 'it', 'ja', 'ko', 'lt', 'lv', 'mk', 'ml', 'nb', 'nds', 'nl', 'oc',
     'pa', 'pl', 'pt', 'pt_BR', 'ro', 'ru', 'sk', 'sl', 'sr', 'sr@latin', 'sv',
     'te', 'tg', 'th', 'tr', 'uk', 'zh_CN', 'zh_HK', 'zh_TW'])

# Vala part needs linking separately because the C part depends on
# 'uuid', but libuuid isn't available as a package for Vala.
# FIXME: That doesn't work though because then the Vala name of the
# package is wrong...
libtracker_sparql_vala = static_library(
    'libtracker-sparql-vala',
    'src/libtracker-sparql/tracker-builder.vala',
    'src/libtracker-sparql/tracker-connection.vala',
    'src/libtracker-sparql/tracker-cursor.vala',
    'src/libtracker-sparql/tracker-namespace.vala',
    'src/libtracker-sparql/tracker-utils.vala',
    dependencies: [gio, glib, gobject],
    vala_args: [
        '--debug',
        '--library', 'tracker-sparql-' + tracker_api_version,
        '--pkg', 'posix',
        '--target-glib', glib_required,
        '--vapi', 'tracker-sparql.vapi'],
)

libtracker_sparql = library(
    'libtracker-sparql',
    'src/libtracker-sparql/tracker-uri.c',
    'src/libtracker-sparql/tracker-version.c',
    c_args: ['-DTRACKER_COMPILATION'],
    dependencies: [gio, glib, gobject, uuid],
    link_with: libtracker_sparql_vala
)

executable(
    'tracker-needle',
    'src/tracker-needle/config.vapi',
    'src/tracker-needle/tracker-needle.vala',
    'src/tracker-needle/tracker-history.vala',
    'src/tracker-needle/tracker-needle.vala',
    'src/tracker-needle/tracker-query.vala',
    'src/tracker-needle/tracker-result-store.vala',
    'src/tracker-needle/tracker-stats.vala',
    'src/tracker-needle/tracker-tags-view.vala',
    'src/tracker-needle/tracker-utils.vala',
    'src/tracker-needle/tracker-view.vala',
    dependencies: [gtk3],
    # FIXME: we shouldn't need to specify libtracker-sparql-vala here,
    # surely? It's linked against libtracker-sparql already...
    link_with: [libtracker_sparql, libtracker_sparql_vala],
    c_args: [
        '-DSRCDIR="' + meson.current_source_dir() + '"',
        '-include', 'config.h'
    ]
)
