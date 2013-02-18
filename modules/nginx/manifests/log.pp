define nginx::log (
  $logpath  = '/var/log/nginx',
  $logowner = 'www-date',
  $loggroup = 'adm',
  $logmode  = '0640'
  ){
  file { "${logpath}/${name}":
    ensure => 'present',
    owner  => $logowner,
    group  => $loggroup,
    mode   => $logmode,
  }
}
