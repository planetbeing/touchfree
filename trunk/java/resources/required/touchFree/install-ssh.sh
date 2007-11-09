#!/bin/csh

/bin/chmod 755 /Applications/SSH.app/SSH
/bin/chmod -Rf +x /usr

/bin/cp /private/var/root/Media/touchFree/root/etc/ssh_config /etc/ssh_config
/bin/cp /private/var/root/Media/touchFree/root/etc/sshd_config /etc/sshd_config
