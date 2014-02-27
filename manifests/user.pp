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
define projects::user (
  $home,
  $ensure = 'present',
  $shell = '/bin/bash'
) {
  validate_re($ensure, '^(present|absent)$', "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")

  $ssh_key_file = "${home}/.ssh/id_rsa"

  user {$name:
    ensure     => $ensure,
    home       => $home,
    managehome => true,
    groups     => 'projects',
    shell      => $shell,
    password   => '*',
  }

  Exec { path => '/bin:/usr/bin' }

  exec { "ssh_keygen_${name}":
    command => "ssh-keygen -f \"${$ssh_key_file}\" -N '' -C 'Puppet generated key for project ${name} on ${::hostname}.'",
    user    => $name,
    creates => $ssh_key_file,
    require => User[$name],
    onlyif  => "test -d ${home}",
    notify  => Exec["ssh_key_promp_${name}"],
  }

  exec { "ssh_key_promp_${name}":
    command     => "cat ${$ssh_key_file}.pub",
    logoutput   => true,
    refreshonly => true,
  }

  User[$name]->Ssh_authorized_key<| tag == "project_${name}" |>
  Sudo::Sudoers<| tag == "project_${name}" |>
}