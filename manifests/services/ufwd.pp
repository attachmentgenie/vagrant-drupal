class services::ufwd {

    package { ["ufw"]:
        ensure => latest,
        require => Exec["apt_update"],
    }

    exec { "enable-firewall":
        command => "/usr/bin/yes | /usr/sbin/ufw enable",
        unless => "/usr/sbin/ufw status | grep \"Status: active\"",
        require => Package["ufw"]
    }
}