class nginx::package {

  include govuk::ppa

  case $::lsbdistcodename {
    'precise': {
      $version = '1.4.1-1ppa0~precise'
    }
    default: {
      $version = '1.4.1-1ppa0~lucid'
    }
  }

  # nginx package actually has nothing useful in it; we need nginx-full
  package { 'nginx':
    ensure => purged,
  }

  package { 'nginx-full':
    ensure => $version,
    notify => Class['nginx::restart'],
  }

}
