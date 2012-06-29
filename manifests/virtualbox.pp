import "accounts/*"
import "apps/*"
#import "files/*"
import "services/*"

#Create users.
include accounts::groups
realize(Group["puppet"])

include apt

#Setup services
include services::ntpd
include services::sshd
include services::ufwd
include services::httpd
include services::mysqld

#Install applications
include apps::baseApps
include apps::drupal