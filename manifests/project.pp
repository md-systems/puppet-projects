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
define projects::project (
  $ensure = 'present',
  $mysql = undef,
  $vhost = undef,
  $drupal = false,
  $projects_dir = '/home/projects'
) {

  validate_re($ensure, '^(present|absent)$', "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")

  $user_home = "${projects_dir}/${name}"

  projects::user{ $name:
    ensure => $ensure,
    home   => $user_home,
  }

  if $vhost {
    include projects::install::apache
    include projects::install::php

    $vhost_resource = {
      "${name}" => $vhost
    }
    $vhost_defaults = {
      user      => $name,
      user_home => $user_home,
    }
    create_resources('projects::vhost', $vhost_resource, $vhost_defaults)
    Projects::User[$name]->Projects::Vhost[$name]
  }
  else {
    projects::vhost { $name:
      ensure    => 'absent',
      user      => $name,
      user_home => $user_home,
    }
  }

  if $mysql {
    include projects::install::mysql
    $mysql_resource = {
      "${name}" => $mysql
    }
    $mysql_defaults = {
      user      => $name,
      user_home => $user_home
    }
    create_resources('projects::mysql', $mysql_resource, $mysql_defaults)
    Projects::User[$name]->Projects::Mysql[$name]
  }
  else {
    projects::mysql { $name:
      ensure    => 'absent',
      user      => $name,
      user_home => $user_home,
      password  => undef,
    }
  }

  if $drupal {
    include projects::install::drush
  }
}
