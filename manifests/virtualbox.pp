$drupal_version = '7.14'

Exec {
  path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
}
#Setup repositories
class { 'apt':
  always_apt_update => true,
}

#Install default applications
case $::operatingsystem {
  default: { $default_packages = ['tree','zip','unzip','subversion','wget','ant','ant-contrib','python-setuptools'] }
}

package { $default_packages:
  ensure  => latest,
}

#Setup services
class { 'ufw': }

class { 'ssh::client': }
ufw::allow { 'allow-ssh-from-all':
  port => 22,
}

class { 'ntp': }
ufw::allow { 'allow-ntp-from-all':
  port => 123,
}

case $::operatingsystem {
  default: { $project_packages = ['php5-cli','php-pear','php5-mysql','php5-gd'] }
}

package { $project_packages:
  ensure   => latest,
}

class { 'apache': }
class { 'apache::php': }

class { 'mysql': }
class { 'mysql::server':
  config_hash => { 'root_password' => 'vagrant' }
}

file { '/home/vagrant/drupal-data':
  ensure => directory,
  owner  => 'www-data',
  group  => 'www-data',
  mode   => '0777',
}

exec { 'download-drupal':
  command => "wget http://ftp.drupal.org/files/projects/drupal-$drupal_version.zip -O /home/vagrant/drupal-$drupal_version.zip",
  creates => "/home/vagrant/drupal-$drupal_version.zip",
  require => Package[$default_packages],
}

exec { 'unzip-drupal-zip':
  command => "unzip /home/vagrant/drupal-$drupal_version.zip  -d /home/vagrant",
  creates => "/home/vagrant/drupal-$drupal_version",
  require => Exec['download-drupal'],
}

file { "/home/vagrant/drupal-$drupal_version":
  ensure  => directory,
  owner   => 'www-data',
  group   => 'www-data',
  recurse => true,
  mode    => '0777',
  require => Exec['unzip-drupal-zip'],
}

file { '/home/vagrant/drupal-www':
  ensure  => link,
  target  => "/home/vagrant/drupal-$drupal_version",
  require => File["/home/vagrant/drupal-$drupal_version"],
}

apache::vhost { 'drupal.test':
  priority           => '20',
  port               => '80',
  docroot            => '/home/vagrant/drupal-www',
  configure_firewall => false,
  require            => [Exec['unzip-drupal-zip'],File['/home/vagrant/drupal-data']],
}
ufw::allow { 'allow-http-from-all':
  port => 80,
}

mysql::db { 'drupal':
  user     => 'drupal',
  password => 'drupal',
  host     => 'localhost',
  grant    => ['all'],
  require  => Class['mysql::server'],
}