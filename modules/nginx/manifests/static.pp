define nginx::static($protected = true, $aliases = [], $ssl_only = false) {
  file { "/etc/nginx/sites-available/$name":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('nginx/static-vhost.conf'),
    require => Class['nginx::install'],
    notify  => Exec['nginx_reload'],
  }

  case $protected {
    default: {
      file { "/etc/nginx/htpasswd/htpasswd.$name":
        ensure => present,
        source => [
          "puppet:///modules/nginx/htpasswd.$name",
          'puppet:///modules/nginx/htpasswd.backend',
          'puppet:///modules/nginx/htpasswd.default'
        ],
      }
    }
    false: {
      file { "/etc/nginx/htpasswd/htpasswd.$name":
        ensure => absent
      }
    }
  }

  nginx::ssl { $name: }
  nginx::site { $name: }
}
