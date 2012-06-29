class services::sshd {

    case $::operatingsystem {
        default: { $ssh_packages = ["openssh-client", "openssh-server"] }
    }

    package { $ssh_packages:
        ensure  => installed,
        require => Exec["apt_update"],
    }

    service { sshd:
            name => $::operatingsystem ? {
                default => "ssh",
            },
            enable  => true,
            ensure  => running,
            require => Package[$ssh_packages]
        }

    exec { "allow-connect-sshd":
        command => "/usr/sbin/ufw allow 22",
        unless => "/usr/sbin/ufw status | grep \"22.*ALLOW.*Anywhere\\|Status: inactive\"",
        require => [Package["ufw"], Exec["enable-firewall"],Service["sshd"]]
    }
}