# == Class: projects
#
# A projects lives inside an own user home. Participants expected to work on
# that project can access the project bei either ssh to the server with the
# projects username or their own name and use sudo to switch into the project.
#
# A project can have a MySQL database. A MySQL config file is written for the
# project user.
#
# A project can also have a vhost. The docroot is place at ~/www. Logs are
# written to ~/log
#
# === Parameters
#
# Document parameters here.
#
# [*projects*]
#   A hash containing multiple projects with their configurations.
#
# [*projects_dir*]
#   All projects root are created inside the projects_dir.
#   Defaults to '/home/projects'
#
# === Examples
#
#  class { 'projects':
#    projects => {
#      'foo' => {
#        'mysql' => { 'password' => 'foo bar' }
#        'vhost' => { 'ensure' => 'present' }
#      },
#      'bar' => {
#        'mysql' => { 'password' => 'bar baz' }
#        'vhost' => {
#          'repository' => {
#             'source' => http://git.drupal.org/project/drupal.git
#          }
#        }
#      }
#    },
#    projects_dir => '/home/example_projects',
#  }
#
# === Authors
#
# Christian Haeusler <christian.haeusler@md-systems.ch>
#
# === Copyright
#
# Copyright 2013 MD Systems.
#
# @todo https://github.com/tPl0ch/puppet-composer might be handy too.
class projects (
  $projects = {},
  $projects_dir = '/home/projects'
) {

  # @todo make this work even if users have roles not existing on current host.
  Class['system::groups']
    -> User<| groups == 'developers' |>
    -> Ssh_authorized_key<| tag == 'developers' |>

  file { $projects_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  group {'projects':
    ensure => 'present',
  }

  $project_defaults  = {
    projects_dir => $projects_dir,
    require      => [File[$projects_dir], Group['projects']],
  }

  create_resources('projects::project', $projects, $project_defaults)
}
