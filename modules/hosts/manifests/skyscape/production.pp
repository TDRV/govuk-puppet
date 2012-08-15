class hosts::skyscape::production {
  # These are real hosts (1-1 mapping between Host and Service)
  # Anything that ends .cluster is maintained for backwards compatibility with EC2
  host { 'ip-10-0-0-6.mgmt-sky.internal':       ip => '10.0.0.6',   host_aliases => [ 'ip-10-0-0-6', 'puppet', 'puppet.production.internal' ] }
  host { 'ip-10-0-0-8.mgmt-sky.internal':       ip => '10.0.0.8',   host_aliases => [ 'ip-10-0-0-8', 'jenkins', 'jenkins.production.internal' ] }
  host { 'ip-10-0-0-11.mgmt-sky.internal':      ip => '10.0.0.11',  host_aliases => [ 'ip-10-0-0-11', 'jumpbox1' ] }
  host { 'ip-10-0-0-12.mgmt-sky.internal':      ip => '10.0.0.12',  host_aliases => [ 'ip-10-0-0-12', 'jumpbox2' ] }
  host { 'ip-10-0-0-20.mgmt-sky.internal':      ip => '10.0.0.20',  host_aliases => [ 'ip-10-0-0-20', 'monitoring', 'monitoring.production.internal', 'monitoring.cluster' ] }
  host { 'ip-10-0-0-21.mgmt-sky.internal':      ip => '10.0.0.21',  host_aliases => [ 'ip-10-0-0-21', 'logging', 'logging.production.internal', 'graylog.cluster' ] }

  host { 'ip-10-2-0-2.frontend-sky.internal':   ip => '10.2.0.2',   host_aliases => [ 'ip-10-2-0-2', 'production-frontend'] }
  host { 'ip-10-2-0-3.frontend-sky.internal':   ip => '10.2.0.3',   host_aliases => [ 'ip-10-2-0-3', 'production-frontend-1'] }
  host { 'ip-10-2-0-4.frontend-sky.internal':   ip => '10.2.0.4',   host_aliases => [ 'ip-10-2-0-4', 'production-frontend-2'] }

  #TODO: change router.cluster to load balanced cluster ip
  host { 'ip-10-1-0-3.router-sky.internal':     ip => '10.1.0.3',   host_aliases => [ 'ip-10-1-0-3', 'production-cache', 'router.cluster'] }
  host { 'ip-10-1-0-4.router-sky.internal':     ip => '10.1.0.4',   host_aliases => [ 'ip-10-1-0-4', 'production-cache-1'] }
  host { 'ip-10-1-0-5.router-sky.internal':     ip => '10.1.0.5',   host_aliases => [ 'ip-10-1-0-5', 'production-cache-2'] }

  host { 'ip-10-3-0-5.backend-sky.internal':    ip => '10.3.0.5',   host_aliases => [ 'ip-10-3-0-5', 'production-support', 'support.cluster'] }
}
