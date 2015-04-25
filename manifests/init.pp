# == Class: sabnzbd
#
# This class installs and configures sabnzbd.
#
# === Parameters
#
# [*user*]
#   Specify the user to run sickbeard as. The user will be automatically
#   created. Defaults to "sabnzbd".
# [*config_path*]
#   Full path to the config file to use. Defaults to sabnzbd user's home
#   directory.
# [*host*]
#   The IP address sabnzbd should listen on. Defaults to 0.0.0.0
# [*port*]
#   Port to listen on. Defaults to 8180.
# [*extraopts*]
#   An optional set of parameters to pass to the daemon
# [*enable_https*]
#   Set to 1 to enable https. Defaults to 0 (disabled)
# [*https_port*]
#   https port to use if enabled. Defaults to 9190.
# [*api_key*]
#   Set the api key to use. A default key is used.
# [*nzb_key*]
#   API key for just nzb interactions.
# [*download_dir*]
#   Temporary download location. Defaults to /home/sabnzbd/Downloads/incomplete
# [*complete_dir*]
#   Completed download location. Defaults to /home/sabnzbd/Downloads/complete
# [*login_username*]
#   Username to use for password protection of sabnzbd. Default is none.
# [*login_password*]
#   Password to use for password protection of sabnzbd. Default is none.
# [*servers*]
#   A user supplied hash of usenet servers to connect to. *required*
# [*categories*]
#   A user supplied hash of an optional set of categories to setup
#
# === Variables
#
# [*unrar*]
#   The package to select for unraring files. unrar-free on debian is used,
#   but this has problems with some RAR files. Will add a PPA in future.
#
# === Examples
#
#  $servers = {
#    myprovider => { 'server_url'  => 'news.provider1.com',
#                    'port'        => '119',
#                    'connections' => '10',
#    },
#    backup => { 'server_url'  => 'news.provider2.com',
#                'port'        => '119',
#                'connections' => '5',
#                'backup_server' => '1',
#     }
#  }
#
#  $categories = {
#    tv     => { 'directory' => 'TV' },
#    movies => { 'directory' => '/opt/share/movies' },
#  }
#
#  class { 'sabnzbd':
#    servers  => $servers,
#    categories => $categories,
#  }
#
# === Authors
#
# Andrew Harley <morphizer@gmail.com>
#

class sabnzbd (
  $user           = $::sabnzbd::params::user,
  $config_path    = $::sabnzbd::params::config_path,
  $host           = $::sabnzbd::params::host,
  $port           = $::sabnzbd::params::port,
  $extraopts      = undef,
  $enable_https   = $::sabnzbd::params::enable_https,
  $https_port     = $::sabnzbd::params::https_port,
  $api_key        = $::sabnzbd::params::api_key,
  $nzb_key        = $::sabnzbd::params::nzb_key,
  $download_dir   = $::sabnzbd::params::download_dir,
  $complete_dir   = $::sabnzbd::params::complete_dir,
  $login_username = $::sabnzbd::params::login_username,
  $login_password = $::sabnzbd::params::login_password,
  $servers        = {},
  $categories     = {}
) inherits sabnzbd::params {
 

  case $::osfamily {
	'Redhat': { 
	  package { 'rpmforge-release':
          	provider => 'rpm',
          	ensure => installed,
          	source => 'http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm',
        	}
	  package { 'unrar':
	  	ensure => installed,
		}
	  package { 'epel-release':
	  	ensure => installed,
    }
	  yumrepo { 'sabnzbd':
          	name => 'SABnzbd',
          	descr => 'SABnzbd for RHEL $::operatingsystemmajrelease and clones - $basearch - Base',
          	baseurl => "https://dl.dropboxusercontent.com/u/14500830/SABnzbd/RHEL-CentOS/${::operatingsystemmajrelease}",
          	failovermethod => 'priority',
          	enabled => 1,
          	gpgcheck => 0,
		}
  	  package { $sabnzbd::params::package:
    		ensure  => installed,
    		require => Package[ 'unrar', 'epel'],
  		}
	  file { $::sabnzbd::params::service_config:
    		ensure  => file,
    		require => $::sabnzbd::param::package,
    		content => template('sabnzbd/sabnzbd_rh.erb'),
    		notify  => $::sabnzbd::param::service
  		}  
	  service { $::sabnzbd::params::service:
    		enable     => true,
    		hasrestart => true,
    		require    => Package['SABnzbd']
  		}
        }
	'Debian': {	
	#  Exec["apt-update"] -> Package <| |>
	# make it run apt-get update first
  	  exec { "apt-update":
    		command => "/usr/bin/apt-get update"
  		}	

	  package { 'unrar-free':
		ensure => installed,
		}
  	  package { $sabnzbd::params::package:
    		ensure  => installed,
    		require => Package[ 'unrar-free'],
  		}
	  file { $::sabnzbd::params::service_config:
    		ensure  => file,
    		require => $::sabnzbd::param::package,
    		content => template('sabnzbd/sabnzbdplus.erb'),
    		notify  => $::sabnzbd::param::service
  		} 
	  service { $::sabnzbd::params::service:
    		enable     => true,
    		hasrestart => true,
    		ensure     => running,
    		require    => Package['SABnzbd']
  		}
 
 	}
  }

  # on ubuntu it's available in official repositories since jaunty
  # though it's an old version. Will add the custom ppa soon.

  user { $::sabnzbd::params::user:
    ensure     => present,
    comment    => 'SABnzbd user, created by Puppet',
    system     => true,
    managehome => true,
    require    => $::sabnzbd::param::package
  }

  file { $config_path:
    ensure  => file,
    require => $::sabnzbd::param::package,
    content => template('sabnzbd/sabnzbd.ini.erb'),
    notify  => $::sabnzbd::param::service,
    owner   => $user,
    group   => $user
  }

}
