class graphite::package {
  include apt

  apt::deb_repository { 'ubuntuus':
    url     => 'http://us.archive.ubuntu.com/ubuntu',
    dist    => 'lucid',
    repo    => 'multiverse',
  }

  package{['python-flup', 'python-carbon', 'python-graphite-web', 'python-txamqp', 'python-whisper', 'libapache2-mod-fastcgi']:
    ensure  => present,
    require => Apt::Deb_repository['ubuntuus'];
  }

  # these file resources should probably be fixed in the source debs, but meh
  file { '/opt/graphite/graphite/manage.py':
    mode    => '0755',
    require => Package['python-graphite-web'],
  }

  file { '/var/log/graphite':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }
}
