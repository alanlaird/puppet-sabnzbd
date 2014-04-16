# == Class: sabnzbd::params
#
# Provides some sane default settings for getting started with
# sabnzbd.
class sabnzbd::params {

  # These settings allow sabnzbd to start
  $user        = 'sabnzbd'
  $host        = '0.0.0.0'
  $port        = '8080'

  # General configuration settings
  $enable_https = '0'
  $https_port   = '9190' # only used if above is true
  $api_key      = '155afa0330c150972ce3c6efe2d59533'
  $nzb_key      = 'b9606ae4f0424a23aad94f1a30cc5b8d'
  $download_dir = 'Downloads/incomplete'
  $complete_dir = 'Downloads/complete'

  # Login settings for sabnzbd frontend, blank means no login
  $login_username     = ''
  $login_password     = ''

  case $::osfamily {
    'Debian': {
      $package    = [ 'sabnzbdplus', 'sabnzbdplus-theme-mobile', 'sabnzbdplus-theme-smpl' ]
      $service	  = 'sabnzbdplus'
      $service_config = '/etc/default/sabnzbdplus'
    }
    'RedHat': {
      $package    = [ 'SABnzbd' ]
      $service    = 'SABnzd'
      $config_path = '/home/sabnzbd/sabnzbd.ini'
      $service_config = '/etc/sysconfig/SABnzbd'
    }
    default: {
      fail("osfamily not supported: ${::osfamily}")
    }
  }

}

