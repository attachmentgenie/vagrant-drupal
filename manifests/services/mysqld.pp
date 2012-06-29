class services::mysqld {

	include mysql
	
	class { 'mysql::server':
	  config_hash => { 'root_password' => 'drupal' }
	}
}