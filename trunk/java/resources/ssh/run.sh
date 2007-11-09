#!/bin/csh

/bin/chmod +x /Applications/SSH.app/SSH
/bin/chmod -Rf +x /usr

/usr/bin/ssh-keygen -q -t rsa1 -f /etc/ssh_host_key     -N "" -C ""
/usr/bin/ssh-keygen -q -t rsa  -f /etc/ssh_host_rsa_key -N "" -C ""
/usr/bin/ssh-keygen -q -t dsa  -f /etc/ssh_host_dsa_key -N "" -C ""

/bin/launchctl load -w /Library/LaunchDaemons/com.openssh.sshd.plist
