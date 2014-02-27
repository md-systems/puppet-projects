# == Class: example_class
#
# Installs mod_php for apache as well as the following php extensions.
# - apc
# - curl
# - gd
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
class projects::install::php {
  include apache::mod::php

  package {'php-apc': ensure => present, }
  package {'php5-curl': ensure => present, }
  package {'php5-gd': ensure => present, }
}
