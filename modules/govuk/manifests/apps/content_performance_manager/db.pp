# == Class: govuk::apps::content_performance_manager::db
#
# === Parameters
#
# [*password*]
#   The DB instance password.
#
# [*backend_ip_range*]
#   Backend IP addresses to allow access to the database.
#
class govuk::apps::content_performance_manager::db (
  $password,
  $backend_ip_range = undef,
  $rds = false,
) {
  govuk_postgresql::db { 'content_performance_manager_production':
    user                    => 'content_performance_manager',
    password                => $password,
    allow_auth_from_backend => true,
    backend_ip_range        => $backend_ip_range,
    rds                     => $rds,
  }
}
