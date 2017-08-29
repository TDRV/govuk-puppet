# == Class: Govuk_containers::App
#
# A defined type which pulls and runs a container with the defined environment
# variables.
#
# === Parameters:
#
# [*image*]
#   The container image to run.
#
# [*port*]
#   An array of local ports to map in the format of ['1234:1234'].
#
# [*ensure*]
#   Whether to ensure the frameworking for the app to exist.
#   Default: present
#
# [*image_tag*]
#   The image tag to run. In our deployment this should not be specified
#   as we will explicitly tag images. However, for local development this
#   parameter can be set.
#
# [*envvars*]
#   An array of environment variables to start the container with.
#
# [*global_env_file*]
#   Location of the file which holds global environment variables assigned
#   to every container that runs.
#
# [*command*]
#   A command to start the container with.
#
# [*restart_attempts*]
#   Amount of times to attempt restarting the container if it's detected
#   as unhealthy.
#   Default is to always try restarting the app a maximum of 3 times.
#
# [*healthcheck_path*]
#   The path where the healthcheck for the application resides.
#
# [*json_healthcheck*]
#   Whether the healthcheck is JSON format.
#
define govuk_containers::app (
  $image,
  $port,
  $ensure = 'present',
  $image_tag = 'current',
  $envvars = [],
  $global_env_file = '/etc/global.env',
  $command = undef,
  $restart_attempts = 3,
  $healthcheck_path = undef,
  $json_healthcheck = false,
) {
  include ::govuk_docker
  include ::govuk_containers::app::config

  validate_array($envvars)
  validate_re($restart_attempts, [ 'never', 'always', '^\d$' ])

  $exposed_port = "${port}:${port}"

  case $restart_attempts {
    'never':  { $restart_arg = '--restart=no' }
    'always': { $restart_arg = '--restart=always' }
    /\d/:   { $restart_arg = "--restart=on-failure:${restart_attempts}" }
    default: { $restart_arg = "--restart=on-failure:${restart_attempts}" }
  }

  # Add any extra parameters as an array
  $extra_params = [
    $restart_arg,
  ]

  ::docker::run { $title:
    ensure           => $ensure,
    net              => 'host',
    image            => "${image}:${image_tag}",
    ports            => [$exposed_port],
    env              => $envvars,
    env_file         => $global_env_file,
    command          => $command,
    extra_parameters => $extra_params,
    subscribe        => Class[Govuk_containers::App::Config],
    require          => Class[Govuk_docker],
  }

  # Provide a symlink to the docker job using the plain app name
  file { "/etc/init.d/${title}":
    ensure => 'link',
    target => "/etc/init.d/docker-${title}",
  }

  if $healthcheck_path {
    @@icinga::check { "check_app_${title}_up_on_${::hostname}":
      ensure              => $ensure,
      check_command       => "check_nrpe!check_app_up!${port} ${healthcheck_path}",
      service_description => "${title} app healthcheck",
      host_name           => $::fqdn,
    }
    if $json_healthcheck {
      include icinga::client::check_json_healthcheck

      $healthcheck_desc      = "${title} app health check not ok"
      $healthcheck_opsmanual = regsubst($healthcheck_desc, ' ', '-', 'G')

      @@icinga::check { "check_app_${title}_healthcheck_on_${::hostname}":
        ensure              => $ensure,
        check_command       => "check_nrpe!check_json_healthcheck!${port} ${healthcheck_path}",
        service_description => $healthcheck_desc,
        host_name           => $::fqdn,
        notes_url           => monitoring_docs_url($healthcheck_opsmanual),
      }
    }
  }

}
