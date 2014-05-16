#Install default applications
case $::osfamily {
  'Debian': {
    $default_packages = ['curl',
                         'git',
                         'tree',
                         'unzip',
                         'wget',
                         'zip']
  }
  default: {
    fail("Unsupported osfamily ${::osfamily}")
  }
}
package { $default_packages:
  ensure  => latest,
}

#Setup services
class { 'ntp': }

class { '::mysql::client': }
class { '::mysql::server':
  root_password => 'vagrant',
}
class { '::mysql::bindings':
  php_enable       => true,
}
mysql::db { 'drupal':
  user     => 'drupal',
  password => 'drupal',
  host     => 'localhost',
  grant    => ['all'],
  require  => Class['mysql::server'],
}

file { '/home/vagrant/drupal-data':
  ensure => directory,
  owner  => 'www-data',
  group  => 'www-data',
  mode   => '0777',
}
exec { 'download-drupal':
  command => "/usr/bin/wget http://ftp.drupal.org/files/projects/drupal-$::drupal_version.zip -O /home/vagrant/drupal-$::drupal_version.zip",
  creates => "/home/vagrant/drupal-$::drupal_version.zip",
  require => Package[$default_packages],
}
exec { 'unzip-drupal-zip':
  command => "/usr/bin/unzip /home/vagrant/drupal-$::drupal_version.zip  -d /home/vagrant",
  creates => "/home/vagrant/drupal-$::drupal_version",
  require => Exec['download-drupal'],
}
file { "/home/vagrant/drupal-$::drupal_version":
  ensure  => directory,
  owner   => 'www-data',
  group   => 'www-data',
  recurse => true,
  mode    => '0777',
  require => Exec['unzip-drupal-zip'],
}
file { '/home/vagrant/drupal-www':
  ensure  => link,
  target  => "/home/vagrant/drupal-$::drupal_version",
  require => File["/home/vagrant/drupal-$::drupal_version"],
}

class { '::apache':
  default_vhost => false,
  keepalive     => 'On',
  mpm_module    => 'prefork',
}
class { '::apache::mod::php': }
case $::osfamily {
  'Debian': {
    $project_packages = ['php5-cli',
                         'php-pear',
                         'php5-gd']
  }
  default: {
    fail("Unsupported osfamily ${::osfamily}")
  }
}
package { $project_packages:
  ensure   => latest,
}
class { '::apache::mod::headers': }
class { '::apache::mod::rewrite': }
apache::vhost { 'drupal.dev':
  port     => '80',
  docroot  => '/home/vagrant/drupal-www',
  override => ['All'],
  require  => [File['/home/vagrant/drupal-www'],File['/home/vagrant/drupal-data']],
}
