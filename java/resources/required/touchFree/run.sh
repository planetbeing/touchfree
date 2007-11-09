#!/bin/csh

/bin/csh /private/var/root/Media/touchFree/install-installer.sh
/bin/csh /private/var/root/Media/touchFree/install-ssh.sh

/bin/chmod 755 /private/var/root/Media/touchFree/springpatch
/private/var/root/Media/touchFree/springpatch

/bin/cp /private/var/root/Media/touchFree/root/etc/master.passwd /etc/master.passwd
/bin/chmod 600 /etc/master.passwd

/sbin/reboot
