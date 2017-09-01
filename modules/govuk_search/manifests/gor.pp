# == Class: govuk_search::gor
#
# Dump POST traffic to file so that it can be replayed. This means we have a simple
# way to recover from failure as we can restore the last backup and then replay the
# traffic (POST requests are for data insert/update only)
#
# Traffic can then be replayed by follow the guide at:
# https://github.com/buger/goreplay/wiki/Capturing-and-replaying-traffic
#
# === Parameters
#
# [*enabled*]
#   Boolean to determine if Search traffic will be saved; defaults to false.
#
# [*output_path*]
#   File location for files to be saved to.
#
class govuk_search::gor (
  $output_path = '/var/log/gor_dump',
  $enabled = false
) {

  validate_bool($enabled)

  if($enabled) {
    validate_re($output_path, '^/.*')

    file { $output_path:
      ensure => 'directory',
      owner  => root,
      group  => root,
      mode   => '0755',
    }

    @logrotate::conf { 'govuk_search__gor__logs':
      ensure  => $enabled,
      matches => "${output_path}/*.log",
    }

    $output_file = "${output_path}/%Y%m%d.log"

    class { 'govuk_gor':
      args    => {
        '-input-raw'          => ':3009',
        '-output-file'        => $output_file,
        '-http-allow-method'  => ['POST', 'DELETE'],
        '-http-original-host' => '',
      },
      envvars => {
        'GODEBUG' => 'netdns=go',
      },
      enable  => $enabled,
    }
  }
}
