# == Define: example_resource
#
# Full description of defined resource type example_resource here.
#
# === Parameters
#
# Document parameters here
#
# [*namevar*]
#   If there is a parameter that defaults to the value of the title string
#   when not explicitly set, you must always say so.  This parameter can be
#   referred to as a "namevar," since it's functionally equivalent to the
#   namevar of a core resource type.
#
# [*basedir*]
#   Description of this variable.  For example, "This parameter sets the
#   base directory for this resource type.  It should not contain a trailing
#   slash."
#
# === Examples
#
# Provide some examples on how to use this type:
#
#   example_class::example_resource { 'namevar':
#     basedir => '/tmp/src',
#   }
#
# === Authors
#
# Christian Haeusler <christian.haeusler@md-systems.ch>
#
# === Copyright
#
# Copyright 2013 MD Systems.
#
define projects::vhost (
  $user,
  $user_home,
  $servername = "${name}.${::fqdn}",
  $serveraliases = undef,
  $repository = undef,
  $ip = $::ipaddress,
  $repository = undef,
  $ensure = 'present'
) {
  validate_re($ensure, '^(present|absent)$', "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")

  $docroot = "${user_home}/www",
  $logroot = "${user_home}/log",

  if $repository {
    $vcsrepo = {
      "${docroot}" => $repository
    }
    $vcsrepo_defaults = {
      ensure   => $ensure,
      provider => git,
      user     => $name,
      before   => File[$docroot],
    }
    create_resources('vcsrepo', $vcsrepo, $vcsrepo_defaults)
  }

  $ensure_dir = $ensure ? {
    'absent' => 'absent',
    default  => 'directory',
  }

  File {
    owner => $user,
    group => $user,
    mode  => '0750',
  }

  file { $docroot:
    ensure => $ensure_dir,
  }

  file { $logroot:
    ensure => $ensure_dir,
  }

  # @todo Custom fragments from hiera config.
  # @todo mail from directive
  if (defined(Class['apache'])) {
    apache::vhost{$servername:
      ensure        => $ensure,
      docroot       => $docroot,
      docroot_group => $user,
      docroot_owner => $user,
      logroot       => $logroot,
      options       => ['FollowSymLinks','MultiViews'],
      override      => ['ALL'],
      port          => '80',
      access_log_pipe   => '||/opt/lumberjack/bin/lumberjack.sh -log-to-syslog=true -config=/etc/lumberjack/lumberjack.conf -',
      access_log_format => '{ \"@timestamp\": \"%{%Y-%m-%dT%H:%M:%S%z}t\", \"@message\": \"%r\", \"@fields\": { \"user-agent\": \"%{User-agent}i\", \"client\": \"%a\", \"duration_usec\": %D, \"duration_sec\": %T, \"status\": %s, \"request_path\": \"%U\", \"request\": \"%U%q\", \"method\": \"%m\", \"referrer\": \"%{Referer}i\" } }',
      serveraliases => $serveraliases,
    }
    File[$logroot]->File[$docroot]->Apache::Vhost[$servername]
  }

  if $ensure == 'present' {
    @@dnsmasq::address { $servername: ip => $ip, }
    # @todo Announce server aliases to dns server.
  }
}
