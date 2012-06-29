class services::httpd {

	include apache
    include apache::php

    exec { "allow-connect-httpd":
        command => "/usr/sbin/ufw allow http",
        unless => "/usr/sbin/ufw status | grep \"80/tcp.*ALLOW.*Anywhere\\|Status: inactive\"",
        require => [Package["ufw"], Exec["enable-firewall"],Service["sshd"]]
    }

    exec { "allow-connect-httpsd":
        command => "/usr/sbin/ufw allow https",
        unless => "/usr/sbin/ufw status | grep \"443.*ALLOW.*Anywhere\\|Status: inactive\"",
        require => [Package["ufw"], Exec["enable-firewall"],Service["sshd"]]
    }
}