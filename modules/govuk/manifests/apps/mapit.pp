# == Class: govuk::apps::mapit
##
# === Parameters
#
# [*enabled*]
#   Should the app exist?
#
# [*port*]
#   What port should the app run on?
#
# [*db_password*]
#   The password for the mapit postgresql role
#
# [*django_secret_key*]
#   The key for Django to use when signing/encrypting sessions.
#
class govuk::apps::mapit (
  $enabled = false,
  $port    = '3108',
  $db_password,
  $django_secret_key = undef,
) {
  if $enabled {
    govuk::app { 'mapit':
      app_type           => 'procfile',
      create_pidfile     => false,
      port               => $port,
      vhost_ssl_only     => true,
      health_check_path  => '/',
      log_format_is_json => false;
    }

    govuk_postgresql::db { 'mapit':
      user       => 'mapit',
      password   => $db_password,
      extensions => ['plpgsql', 'postgis'],
    }

    class { 'postgresql::server::postgis': }

    package {
      [
        # These three packages are recommended when installing geospatial
        # support for Django:
        # https://docs.djangoproject.com/en/1.8/ref/contrib/gis/install/geolibs/
        'binutils',
        'libproj-dev',
        'gdal-bin',
        # This is also needed to be able to install python GDAL packages:
        'libgdal-dev',
      ]:
      ensure => present,
    }
  }

  Govuk::App::Envvar {
    app => 'mapit',
  }

  govuk::app::envvar {
    "${title}-DJANGO_SECRET_KEY":
        varname => 'DJANGO_SECRET_KEY',
        value   => $django_secret_key;
  }
}
