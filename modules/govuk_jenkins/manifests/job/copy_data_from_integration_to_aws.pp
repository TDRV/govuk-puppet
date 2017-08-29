# == Class: govuk_jenkins::job::copy_data_from_integration_to_aws
#
# Create a file on disk that can be parsed by jenkins-job-builder
#
class govuk_jenkins::job::copy_data_from_integration_to_aws (
  $mysql_src_root_pw = undef,
  $mysql_dst_root_pw = undef,
  $pg_src_env_sync_pw = undef,
  $pg_dst_env_sync_pw = undef,
  $whitehall_mysql_password = undef,
  $app_domain = hiera('app_domain'),
) {
  $check_name = 'copy_data_from_integration_to_aws'
  $service_description = 'Copy Data from Integration to Aws'

  $slack_team_domain = 'govuk'
  $slack_room = '2ndline'
  $slack_build_server_url = "https://deploy.${app_domain}/"

  file { '/etc/jenkins_jobs/jobs/copy_data_from_integration_to_aws.yaml':
    ensure  => present,
    content => template('govuk_jenkins/jobs/copy_data_from_integration_to_aws.yaml.erb'),
    notify  => Exec['jenkins_jobs_update'],
  }
}
