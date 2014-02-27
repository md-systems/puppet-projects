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
define projects::mysql (
  $user,
  $user_home,
  $password,
  $ensure = 'present'
) {
  validate_re($ensure, '^(present|absent)$', "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")
  validate_slength($name, 16)
  if !$password and $ensure == 'present' {
    fail("No password or passwordkey provided for project ${name}.")
  }

  if (defined(Class['mysql::server'])) {
    mysql::db { $name:
      ensure   => $ensure,
      user     => $user,
      password => hiera($password, $password),
      host     => 'localhost',
      grant    => ['all'],
    }
  }

  $mysql_conf = "${user_home}/.my.cnf"

  file {$mysql_conf:
    ensure => $ensure,
  }

  Ini_setting {
    path    => $mysql_conf,
    section => 'client',
    ensure  => $ensure,
    require => File[$mysql_conf]
  }

  ini_setting { "${name}-my.cnf-user":
    setting => 'user',
    value   => $user,
  }

  ini_setting { "${name}-my.cnf-password":
    setting => 'password',
    value   => $password,
  }
  ini_setting { "${name}-my.cnf-db":
    setting => 'database',
    value   => $name,
  }
}