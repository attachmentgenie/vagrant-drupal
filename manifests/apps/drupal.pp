class apps::drupal {

    case $::operatingsystem {
        default: { $project_packages = ["php5-mysql","php5-gd"] }
    }

    package { $project_packages:
        ensure   => latest,
        require  => Exec["apt_update"],
    }

    file { "/home/vagrant/drupal-data":
        ensure   => directory,
        owner    => 'www-data',
        group    => 'www-data',
        mode     => '777',
    }

    exec { "download-drupal":
        command => "/usr/bin/wget http://ftp.drupal.org/files/projects/drupal-7.14.zip -O /home/vagrant/drupal-7.14.zip",
        creates => "/home/vagrant/drupal-7.14.zip",
        require => Package[$apps::baseApps::base_packages],
    }

    exec { "unzip-drupal-zip":
        command => "/usr/bin/unzip /home/vagrant/drupal-7.14.zip  -d /home/vagrant",
        creates => "/home/vagrant/drupal-7.14",
        require => Exec['download-drupal'],
    }

    file { "/home/vagrant/drupal-7.14":
        ensure   => directory,
        owner    => 'www-data',
        group    => 'www-data',
        recurse  => true,
        mode     => '777',
        require  => Exec['unzip-drupal-zip'],
    }


    file { "/home/vagrant/drupal-www":
        ensure   => link,
        target  => "/home/vagrant/drupal-7.14",
        require  => File['/home/vagrant/drupal-7.14'],
    }

    apache::vhost { 'drupal.test':
        priority => '20',
        port     => '80',
        docroot  => '/home/vagrant/drupal-www',
        require  => [Exec['unzip-drupal-zip'],File['/home/vagrant/drupal-data']],
    }

    mysql::db { 'drupal7':
  		user     => 'drupal',
  		password => 'drupal',
  		host     => 'localhost',
  		grant    => ['all'],
  		require  => Class['mysql::server'],
	}
}