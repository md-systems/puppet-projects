# == Class: projects::install::apache
#
# Installs apache with itk and mod_rewrite
# The class is not meant to be used on its own but will be included by the
# projects::vhost resource.
#
# === Authors
#
# Christian Haeusler <christian.haeusler@md-systems.ch>
#
# === Copyright
#
# Copyright 2013 MD Systems.
#
class projects::install::apache {
  class {'::apache':
    mpm_module => 'itk'
  }
  include apache::mod::rewrite
}