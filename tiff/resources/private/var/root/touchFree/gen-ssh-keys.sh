#!/bin/csh

if (! -e /etc/ssh_host_key) then
  /usr/bin/ssh-keygen -q -t rsa1 -f /etc/ssh_host_key -N "" -C ""
endif

if (! -e /etc/ssh_host_rsa_key) then
  /usr/bin/ssh-keygen -q -t rsa  -f /etc/ssh_host_rsa_key -N "" -C ""
endif

if (! -e /etc/ssh_host_dsa_key) then
  /usr/bin/ssh-keygen -q -t dsa  -f /etc/ssh_host_dsa_key -N "" -C ""
endif

/bin/rm /System/Library/LaunchDaemons/com.planetbeing.gen-ssh-keys.plist
