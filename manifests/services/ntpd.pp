class services::ntpd {

    case $::operatingsystem {
        default: { $ntp_packages = ["ntp"] }
    }

    package { $ntp_packages:
            ensure  => installed,
            require => Exec["apt_update"],
        }

    service { ntpd:
            name => $::operatingsystem ? {
                default => "ntp",
            },
            enable  => true,
            ensure  => running,
            require => Package[$ntp_packages],
        }

    exec { "allow-connect-ntpd":
        command => "/usr/sbin/ufw allow 123",
        unless => "/usr/sbin/ufw status | grep \"123.*ALLOW.*Anywhere\\|Status: inactive\"",
        require => [Package["ufw"], Exec["enable-firewall"], Service["ntpd"]],
    }
}