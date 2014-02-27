# == Class: example_class
#
# Installs a mysql server, a mysql client and the php bindings.
# The class is not meant to be used on its own but will be included by the
# projects::mysql resource.
#
# === Authors
#
# Christian Haeusler <christian.haeusler@md-systems.ch>
#
# === Copyright
#
# Copyright 2013 MD Systems.
#
class projects::install::mysql {
  include mysql
  include mysql::php
  # @todo Mysql performance http://www.tasktrack.ch/issues/7811
  include mysql::server
}