# == Class: projects::install::drush
#
# Installs drush.
# The class is not meant to be used on its own but will be included by the
# projects::project resource.
#
# === Authors
#
# Christian Haeusler <christian.haeusler@md-systems.ch>
#
# === Copyright
#
# Copyright 2013 MD Systems.
#
class projects::install::drush {
  include pear

  pear::package { 'Console_Table': }
  pear::package { 'drush':
    version    => '6.0.0RC4',
    repository => 'pear.drush.org',
  }
}
