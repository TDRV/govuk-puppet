define datainsight::collector {

  # Variable setup
  $domain = extlookup('app_domain')
  $vhost = "datainsight-${title}-collector"
  $vhost_full = "${vhost}.${domain}"

  include datainsight::config::google_oauth

  file { "/data/vhost/${vhost_full}":
    ensure => directory,
    owner  => 'deploy',
    group  => 'deploy';
  }

  file { "/var/apps/${vhost}":
    ensure => symlink,
    owner  => 'deploy',
    target => "/data/vhost/${vhost_full}/current"
  }

  file { "/var/log/${vhost}":
    ensure => symlink,
    owner  => 'deploy',
    target => "/data/vhost/${vhost_full}/current/log"
  }

  @logstash::collector { "app-${vhost}":
    content => template("datainsight/collector_logstash.conf.erb"),
  }

  @logrotate::conf { "${vhost}-app":
    matches => "/data/vhost/${vhost_full}/shared/log/*.log",
  }

  # Ensure config dir exists
  file { "/etc/govuk/${vhost}":
    ensure  => 'directory',
    purge   => true,
    recurse => true,
    force   => true,
    notify  => Govuk::App::Service[$vhost],
  }

  # Ensure env dir exists
  file { "/etc/govuk/${vhost}/env.d":
    ensure  => 'directory',
    purge   => true,
    recurse => true,
    force   => true,
    notify  => Govuk::App::Service[$vhost],
  }

  Govuk::App::Envvar { app => $vhost }

  govuk::app::envvar {
    "${vhost}-GOVUK_USER":
      varname => "GOVUK_USER",
      value   => "deploy";
    "${vhost}-GOVUK_GROUP":
      varname => "GOVUK_GROUP",
      value   => "deploy";
    "${vhost}-GOVUK_APP_NAME":
      varname => "GOVUK_APP_NAME",
      value   => $vhost;
    "${vhost}-GOVUK_APP_ROOT":
      varname => "GOVUK_APP_ROOT",
      value   => "/var/apps/${vhost}";
    "${vhost}-GOVUK_APP_LOGROOT":
      varname => "GOVUK_APP_LOGROOT",
      value   => "/var/log/${vhost}";
    "${vhost}-GOVUK_STATSD_PREFIX":
      varname => "GOVUK_STATSD_PREFIX",
      value   => "govuk.app.${vhost}.${::hostname}";
  }
}
