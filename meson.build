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
upower = dependency('libupower-glib', version: '> 0.9.0', required: false)
zlib = dependency('zlib')

# These two don't have pkg-config files.
libgif = meson.get_compiler('c').find_library('libgif', required: false)
libjpeg = meson.get_compiler('c').find_library('libjpeg', required: false)

libmath = meson.get_compiler('c').find_library('m')

# FIXME: here we work around a quirk todo with Meson and Vala: the 'uuid'
# pkg-config component corresponds to 'libuuid.vapi', but Meson assumes that
# .vapi name always matches pkg-config name, and will add `--pkg uuid` to the
# Vala commandline. By finding 'uuid' using find_library() instead, we get
# a dependency object back that won't cause any `--pkg` arguments to be added
# to the Vala commandline, but still works as expected for C code.
uuid = meson.get_compiler('c').find_library('uuid')

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

libtracker_common = library(
    'tracker-' + tracker_api_version + '/libtracker-common',
    'src/libtracker-common/tracker-date-time.c',
    'src/libtracker-common/tracker-dbus.c',
    'src/libtracker-common/tracker-file-utils.c',
    'src/libtracker-common/tracker-ioprio.c',
    'src/libtracker-common/tracker-log.c',
    'src/libtracker-common/tracker-sched.c',
    'src/libtracker-common/tracker-type-utils.c',
    'src/libtracker-common/tracker-utils.c',
    'src/libtracker-common/tracker-locale.c',
    'src/libtracker-common/tracker-parser-utils.c',
    'src/libtracker-common/tracker-language.c',
    # FIXME: need to link against -lkvm on OpenBSD, see configure.ac
    dependencies: [gio_unix, glib, libmath],
    c_args: [
        '-DSHAREDIR="' + get_option('datadir') + '"',
        '-DTRACKER_COMPILATION',
        '-I' + meson.source_root() + '/src',
    ],
)

libtracker_sparql_intermediate = static_library(
    'tracker-sparql-' + tracker_api_version,
    # The .vapi name is taken from the first source file in Meson, so this is
    # actually a symlink to the real tracker-namespace.vala file.
    'src/libtracker-sparql/tracker-sparql.vala',
    'src/libtracker-sparql/tracker-builder.vala',
    'src/libtracker-sparql/tracker-connection.vala',
    'src/libtracker-sparql/tracker-cursor.vala',
    'src/libtracker-sparql/tracker-utils.vala',
    'src/libtracker-sparql/tracker-uri.c',
    'src/libtracker-sparql/tracker-version.c',
    link_with: [libtracker_common],
    dependencies: [gio, glib, gobject, uuid],
    c_args: [
        '-DTRACKER_COMPILATION',
    ],
    vala_args: [
        '--debug',
        '--pkg', 'posix',
        # FIXME: Meson has code to add --target-glib automatically, but it
        # doesn't seem to work here.
        '--target-glib', glib_required,
    ],
)

libtracker_data = library(
    'tracker-' + tracker_api_version + '/libtracker-data',
    # The .vapi name is taken from the first source file in Meson
    'src/libtracker-data/tracker-sparql-query.vala',
    'src/libtracker-data/tracker-vala-namespace.vala',
    'src/libtracker-data/tracker-sparql-expression.vala',
    'src/libtracker-data/tracker-sparql-pattern.vala',
    'src/libtracker-data/tracker-sparql-scanner.vala',
    'src/libtracker-data/tracker-turtle-reader.vala',
    'src/libtracker-common/libtracker-common.vapi',
    'src/libtracker-data/libtracker-data.vapi',
    'src/libtracker-data/tracker-class.c',
    'src/libtracker-data/tracker-collation.c',
    'src/libtracker-data/tracker-crc32.c',
    'src/libtracker-data/tracker-data-backup.c',
    'src/libtracker-data/tracker-data-manager.c',
    'src/libtracker-data/tracker-data-query.c',
    'src/libtracker-data/tracker-data-update.c',
    'src/libtracker-data/tracker-db-config.c',
    'src/libtracker-data/tracker-db-interface.c',
    'src/libtracker-data/tracker-db-interface-sqlite.c',
    'src/libtracker-data/tracker-db-manager.c',
    'src/libtracker-data/tracker-db-journal.c',
    'src/libtracker-data/tracker-db-backup.c',
    'src/libtracker-data/tracker-namespace.c',
    'src/libtracker-data/tracker-ontology.c',
    'src/libtracker-data/tracker-ontologies.c',
    'src/libtracker-data/tracker-property.c',
    link_with: [libtracker_common, libtracker_sparql_intermediate],
    dependencies: [gio_unix, glib, sqlite, uuid, zlib],
    c_args: [
        '-DSHAREDIR="' + get_option('datadir') + '"',
        '-DTRACKER_COMPILATION',
        '-I' + meson.source_root() + '/src',
    ],
    vala_args: [
        '--debug',
        '--pkg', 'posix',
        # FIXME: Meson has code to add --target-glib automatically, but it
        # doesn't seem to work here.
        '--target-glib', glib_required,
    ]
)

libtracker_bus = static_library(
    'tracker-bus',
    # The .vapi name is taken from the first source file in Meson
    'src/libtracker-bus/tracker-bus.vala',
    'src/libtracker-bus/tracker-namespace.vala',
    'src/libtracker-bus/tracker-array-cursor.vala',
    'src/libtracker-bus/tracker-bus-fd-cursor.vala',
    'src/libtracker-common/libtracker-common.vapi',
    link_with: [libtracker_common, libtracker_sparql_intermediate],
    dependencies: [gio, gio_unix],
    c_args: [
        '-DNO_LIBDBUS',
        '-DTRACKER_COMPILATION',
        '-I' + meson.source_root() + '/src',
    ],
    vala_args: [
        '--debug',
        '--pkg', 'posix',
        # FIXME: Meson has code to add --target-glib automatically, but it
        # doesn't seem to work here.
        '--target-glib', glib_required,
    ],
)

libtracker_direct = static_library(
    'tracker-direct',
    # The .vapi name is taken from the first source file in Meson
    'src/libtracker-direct/tracker-direct.vala',
    'src/libtracker-direct/tracker-namespace.vala',
    'src/libtracker-common/libtracker-common.vapi',
    'src/libtracker-data/libtracker-data.vapi',
    'src/libtracker-data/tracker-sparql-query.vapi',
    'src/libtracker-sparql/tracker-sparql-' + tracker_api_version + '.vapi',
    link_with: [libtracker_data, libtracker_sparql_intermediate],
    dependencies: [gio],
    vala_args: [
        '--debug',
        '--pkg', 'posix',
        # FIXME: Meson has code to add --target-glib automatically, but it
        # doesn't seem to work here.
        '--target-glib', glib_required,
    ],
)

libtracker_sparql = library(
    'tracker-sparql-' + tracker_api_version,
    'src/libtracker-sparql-backend/tracker-backend.vala',
    link_with: [libtracker_sparql_intermediate, libtracker_bus, libtracker_direct]
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
    link_with: [libtracker_sparql],
    c_args: [
        '-DSRCDIR="' + meson.current_source_dir() + '"',
        '-include', 'config.h'
    ]
)
