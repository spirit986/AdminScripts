# Linux Cheatsheet Notes

---
## General - Linux ALL
---
Fix webserver permissions
```bash
sudo chown -R www-data:dev-mysitenamehere .
sudo find . -type f -exec chmod 644 {} \;
sudo find . -type d -exec chmod 755 {} \;
```

Get the ip address
```bash
ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'
```

Get the ip address, alternative
```bash
ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
```

Update /etc/hosts with the IP/HOSTNAME of the server
```bash
IPADDR=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
```

Add new line character at the end of file in bash
```bash
echo "" >> file.txt
sed -i '' -e '$a\' file.txt
```

The ultimate grep
```bash
# -r Recusive, -n Display line number, -w Whole words, -i Ignore case, -I Ignore binary
grep -rnwiI /path/to/dir -e "Strng to Search"
```

Filter out the comments from a file with grep
```bash
# -o: prints only matched part of the line
# first ^: beginning of the line
# [^#]*: any character except # repeated zero or more times
grep -o '^[^#]*' file
```

Show listening ports and processes
```bash
netstat -tulnp
```

Show the routing table
```bash
netstat -nr
```

Netstat filter out the uniques
```bash
# https://www.blackmoreops.com/2014/09/25/find-number-of-unique-ips-active-connections-to-web-server/

netstat -antu | grep ':80\|:443' | grep -v LISTEN | awk '{print $5}' | cut -d: -f1 | sort | uniq -c

netstat -antu | grep ':80\|:443' | grep -v LISTEN | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn

netstat -antu | grep -v LISTEN | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn
```

Filtering with awk
```bash
cat /var/log/toptal/access.log | awk -F \" '{print $6}' | sort -n | uniq -c | grep -v - | sort -rn | head
```

Check top outgoung connecitons
```bash
netstat -nputw | awk '{print $5}' | cut -d: -f1 | sort | uniq -c
```

DU (check disc usage)
```bash
# Current Directory
du -schx

# Inspect
du -ch --max-depth=1 /

## Disk size in MB ordered from most usage to less usage
du -sm * | sort -rn
```

NCDU - a smarter way to check disk usage
```bash
ncdu -rx /
```

Convert ssh public key into .pub format
```bash
ssh-keygen -f privatekey.pem -i
```

Get the key based on a fingerprint
```bash
ssh-keygen -lf pub.key
```

Rsync crash course
```bash
# Copy a single file over SSH that listens on port 9022 on the remote machine also show a progress bar
rsync -Wzvh --progress -e "ssh -p 9022" username@172.16.0.50:/media/shared/xvda.vmdk /mnt/d/VMs/

# Copy recursively (the -a flag)
rsync -Wazvh -progress -e "ssh -p 9022" username@172.16.0.50:/media/ /destination

# Copy files localy
rsync src-file dst-file

```

Count number of processes per service
```bash
pidof httpd | wc -w #Will return the number of httpd processes running

# .. or
pgrep -c 'httpd|apache2'#This version is going to work on redhat/centos/suse AND ubuntu/debian systems
```

List services on a Systemd host
```bash
ls /etc/systemd/system/multi-user.target.wants/*.service
```

Systemd | Systemctl list all services
```bash
systemctl list-units --type=service
```

List network interfaces alternative way
```bash
cat /proc/net/dev
```

Get the linux verion / release
```bash
cat /etc/*release*
```

Bring up the interface using ifconfig and assign IP from a DHCP
```bash
## Very usefull on simple systems that do not have ifup command
ifconfig eth0 0.0.0.0 0.0.0.0 && dhclient
```

Simulate load
```bash
fulload() { dd if=/dev/zero of=/dev/null | dd if=/dev/zero of=/dev/null | dd if=/dev/zero of=/dev/null | dd if=/dev/zero of=/dev/null & }; fulload; read; killall dd
```

Find and list all files in a directory on a given date
```bash
## https://www.cyberciti.biz/faq/unix-linux-list-all-files-modified-on-given-date/
find /storage/log/vmware -newermt 2018-09-06 ! -newermt 2018-09-07 -ls
```

Apache2 list modules
```bash
apachectl -t -D DUMP_MODULES
apache2ctl -M
```

Generate a new initrd
```bash
## Take backup of the old first
mkinitrd /boot/initrd-latest.img $(uname -r)
```

**MTR** (Network trobuleshooting tool)
```bash
## Cool way to check for packet loss between hops
mtr -rwc 100 -i 0.5 -rw www.google.com
mtr -rwc 100 -i 0.5 -rw 10.69.11.8
```

Systemd | List services that depend on another service
```bash
## In this example the services that depend by network-online.target
$ systemctl show -p WantedBy network-online.target
```

Customize the PS1 Prompt
```bash
# Normal user
export PS1="\[\033[38;5;10m\]\n[\$?] \u@\h\[$(tput sgr0)\]\[\033[38;5;15m\]\n\w \\$ \[$(tput sgr0)\]"

# Root user
export PS1="\[\033[38;5;9m\]\n[\$?] \u@\h\[$(tput sgr0)\]\[\033[38;5;15m\]\n\w \\$ \[$(tput sgr0)\]"
```

Get octal file permissions
```bash
## Replace * with the relevant directory or the exact filename that you want to examine.
stat -c "%a %n" *
```

Delete files/folders older than X days
```bash
# the basic format - for files
find /tmp/*/* -mtime +7 -type f -exec rmdir {} \;

# the basic format - for folders
find /tmp/*/* -mtime +7 -type d -exec rmdir {} \;
```

Cool way to keep your SSH session open - can be used in case there is an auto-session-terminate-logout implemented in the system 
```bash
ping 127.0.0.1 >/dev/null 2>&1 &
```

Generate password for htpasswd with `openssl`
```bash
# This will ask for password to be entered for the specified $USERNAME and set the hashed password in /etc/nginx/htpasswd.users
echo "$USERNAME:`openssl passwd -apr1`" | sudo tee -a /etc/nginx/htpasswd.users
```


---
## GIT
---

##### How to use Git branches (Example)
Original source: https://stackoverflow.com/questions/4515644/git-checkout-does-not-change-anything
```bash
git branch
* master
organize

git branch networking
git checkout networking
git branch
master
* networking
organize

## Now Master has been updated many times since anyone has done anything on networking
git pull origin networking
```

##### Git fetch all branches before checkout
```bash
# Clone
git clone git@github.com:greenplum-db/gpdb.git

# Update
git fetch --all
git checkout -b [BRANCH_NAME]
git pull --rebase origin master
git checkout -b BRANCH-NAME
```


##### Git switch to a branch but set to track the changes from the same remote branch
A.K.A. Fix the DETACHED HEAD when checking out to a new branch

**Example:**

```bash
$ git clone https://github.com/phpipam/phpipam.git
$ git status

# On branch master
$ git checkout 1.4
Note: checking out '1.4'.

You are in 'detached HEAD' state. You can look around, make experimental changes and commit them, and you can discard any commits you make in this state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may do so (now or later) by using -b with the checkout command again. 

Example:
  git checkout -b new_branch_name

HEAD is now at 29babcf... Removed minimized js.css


$ git pull

You are not currently on a branch. Please specify which branch you want to merge with. See git-pull(1) for details.

  git pull <remote> <branch>


$ git branch
* (detached from 1.4)
  master


$ git checkout -b 1.4 origin/1.4
Branch 1.4 set up to track remote branch 1.4 from origin. 
Switched to a new branch '1.4'

```

Git see your recent commits
```bash
git log origin/master..HEAD
```

Git see changes from the recent commits
```bash
git diff origin/master..HEAD
```


---
## TAR
---
```bash
# -c : Create a new archive
# -x : Extract the contents of an archive
# -t : Lists the contents of an archive
# -z : Filter the archive through gzip
# -j : Filter the archive through bzip2
# -v : Verbose output
# -f file.tar.gz : Use archive file

# Exclude directories/files with:
# --exclude='dir1'


## CREATING ARCHIVES
# Creating a GZip archive
tar -czvf file.tar.gz /path/to/dir/

# Creating a BZip archive
tar -cjvf file.tar.bz2 /path/to/dir/

# Compress a filename
tar -czvf file.tar.gz /path/to/dir/filename


## EXTRACTING ARCHIVES
# For GZip
tar -xzvf file.tar.gz -C /path/to/destination/dir

# For BZip
tar -xjvf file.tar.bz2 -C /path/to/destination/dir


## LISTING ARCHIVES
# For GZip
tar -tzvf file.tar.gz

# For BZip
tar -tjvf file.tar.bz2
```



---
## Short tutorials and scripts
---
---
##### Resize an XFS root partition on CentOS on the fly

Original source: https://stackoverflow.com/questions/38160794/how-to-resize-root-partition-online-on-xfs-filesystem

1. Increase the disk size from the cloud platform
2. Install cloud-utils-growpart if not present already | `yum install cloud-utils-growpart`
3. Use growpart to incease the partition size: | `growpart /dev/xdva 1 #Where 1 is the partition number`
4. Use `xfs_growfs` to rezise the partition | `xfs_growfs -d /dev/xvda1`


---
##### Move a folder to a separate partition
In the example bellow we will move /var/log on a JIRA server to a separate partition.
```bash
# Fin all processes using files in /var/log and stop them
lsof | grep /var/log

pkill auditd
pkill rsyslogd
service mysqld stop
pkill superviso
pkill puthon
service httpd stop
service docker stop

# Mount the partition /dev/nvme2n1 to a temp place
mount /dev/nvme2n1 /temptmp
rsync -avz --progress /var/log/ /temptmp

# Move away the old /var/log and create a new one
mv -i /var/log /var/log.old
mkdir /var/log

# Mount the partition into /var/log
umount /dev/nvme2n1
mount /dev/nvme2n1 /var/log

# Check /etc/mtab and copy the mount point into /etc/fstab
cat /etc/mtab

vim /etc/fstab
/dev/nvme2n1 /var/log   ext4 rw,relatime,data=ordered 0 0

# reboot in the end
reboot
```


---
##### How to use nc (netcat) instead of telnet

When connection is successfull
```bash
$ nc -zv server.com 5000
Ncat: Version 7.50 ( https://nmap.org/ncat )
Ncat: Connected to 10.65.1.85:5000.
Ncat: 0 bytes sent, 0 bytes received in 0.01 seconds.
```

When connection fails
```bash
$ nc -z server.com 5001
[root@worker01 ~]# nc -v server.com 5001
Ncat: Version 7.50 ( https://nmap.org/ncat )
Ncat: Connection refused.
```


---
##### Secure the linux history
The bellow options will make the linux history with a timestamp, will immediately log the history and will log the history to syslog

```bash
cat >>/etc/profile.d/history.sh <<'EOF'

export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug "$(whoami) [$$] [$PWD] : $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]"; history -a; history -c; history -r;'
export HISTTIMEFORMAT="%F %T "
export HISTFILESIZE="5000"
EOF

cat >>/etc/rsyslog.d/commands.conf <<EOF
local6.* /var/log/commands.log
EOF
```


---
##### Cool timestamp function
Can be used in scripts with #date 
https://www.linode.com/docs/tools-reference/tools/use-the-date-command-in-linux/
```bash
function db_filename () {
	DATE=$(date +%H-%M-%S)
	BACKUP=db-$DATE.sql
	echo $BACKUP
}

BACKUP_PATH=/tmp/$(db_filename)
```

Another example
```bash
$(date "+%FT%T")

# Use this when renaming
{,.$(date "+%FT%T")}
# example: 
mv file{,.$(date "+%FT%T")}
```


---
##### Generate UUID for device
When an interface is new and apropriate configuration files need to be created in `/etc/sysconfig/network-scripts/`
```bash
## Generate interface UUID (examole if the new interface is enp0s8)
uuidgen enp0s8
c347febc-b549-456b-b415-477fa4b392e2

## Configure the new interace
vim /etc/sysconfig/network-scripts/ifcfg-enp0s8

TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s3
UUID=c347febc-b549-456b-b415-477fa4b392e2
DEVICE=enp0s8
ONBOOT=yes
IPADDR=
NETMASK=
GATEWAY=
DNS1=
DNS2=
```


---
##### Create user and give all access
You still need to add password in the end
```bash
sudo su -
FULLNAME="Fname Lname"
USERNAME=flanme
PUBLIC_KEY="ssh-rsa your-public-key name@email.com"
useradd -c "$FULLNAME" -m -s /bin/bash $USERNAME && \
mkdir -p /home/$USERNAME/.ssh/ && \
echo "$PUBLIC_KEY" > /home/$USERNAME/.ssh/authorized_keys && \
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh/ && \
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
chmod 0440 /etc/sudoers.d/$USERNAME

## Use this line if you plan to give the same key to root
cp -R /home/$USERNAME/.ssh .

passwd $USERNAME
```


---
##### Virtual hardware hot-add scripts
I used these for when administering the VMware infra for the VMs to avoid restarting

RAM hot-add script
```bash
root@server:~# cat hot_add_mem.sh

#!/bin/bash
# Bring all new Memory online
for RAM in $(grep line /sys/devices/system/memory/*/state)
do
	echo "Found ram: ${RAM} ..."
	if [[ "${RAM}" == *":offline" ]]; then
		echo "Bringing online"
		echo $RAM | sed "s/:offline$//"|sed "s/^/echo online > /"|source /dev/stdin

	else
		echo "Already online"

	fi
done
```

CPU hot-add script
```bash
root@server:~# cat hot_cpu_add.sh

#!/bin/bash
# Bring CPUs online

for CPU_DIR in /sys/devices/system/cpu/cpu[0-9]*
do
	CPU=${CPU_DIR##*/}
	echo "Found cpu: '${CPU_DIR}' ..."
	CPU_STATE_FILE="${CPU_DIR}/online"

	if [ -f "${CPU_STATE_FILE}" ]; then
		if grep -qx 1 "${CPU_STATE_FILE}"; then
			echo -e "\t${CPU} already online"

		else
			echo -e "\t${CPU} is new cpu, onlining cpu ..."
			echo 1 > "${CPU_STATE_FILE}"
		fi
	
	else
		echo -e "\t${CPU} already configured prior to hot-add"
	fi
done
```

DISK hot-add script
```bash
root@librenms:~# cat rescan.sh

#/bin/bash

# ReScan all SCSI/SATA Hosts
for SHOST in /sys/class/scsi_host/host*; do
	echo -n "Scanning ${SHOST##*/}..."
	echo "- - -" > ${SHOST}/scan
	echo Done
done
```

---
##### VIM
```bash
# Traversing text in inser mode
# https://stackoverflow.com/questions/1737163/traversing-text-in-insert-mode


# Save the file when you eddit without sudo
[bash]
$ :w !sudo tee %
[end]

# VIM useful delete examples
`diw` to delete the current word and ciw to cut the current word.
`de` is like `diw`, however it opens the opportunity to delete every next word just by pressing dot(.).
`di(` delete within the current parents.
`di"` to delete the text between the quotes.
`dab` delete around brackets.
`daB` delete around curly brackets.

# VIM useful cut examples
`ciw` to cut the current word.
`ci"` cut the word inside the quotes.
`ci(` cut the word in the parents.
`C` cut the rest of the line and enter INSERT MODE. This is very useful for cut and paste.

# VIM Miscellaneous useful commands
`zz` Scroll down the screen to make the current line appear in the middle. Very useful to put some chunk of code in focus.
`%` finds and moves the cursor to the matching parentheses.
`:%TOhtml` Creates HTML version of the current document. (Try it, it is very useful).
`vim http://site.com/` Vim can also open up URLs assuming they go directly to static HTML files.

# VIM Search and replace
In its basic form, it is the `:substitute` command or :s for short that searches a text pattern and replaces it with a string. The command has many options and these are the most commonly used ones.

`:%s/something/something_else/g` Find the word something and replace it with something_else in the entire document.
`:s/something/something_else/g` Similarly like the before command. This one just replaces in the current line only.
`:%s/something/something_else/gc` Note the c. It replaces everything but asks for confirmation first.
`:%s/\<something\>/something_else/gc` Changes whole words exactly matching something with something_else but ask for confirmation first.
`:%s/SomeThing/something_else/gic` Here the i flag is used for case insensitive search. And the c flag for confirmation.

# VIM Comment out blocks of code
Enter Blockwise visual mode with CTRL+V and mark the block you wish to comment.
Press capital I and enter the comment string at the beginning of the line (# for bash, or // for C++ etc..)
Press ESC twice and all the lines will be commented out.
```

###### VIM Comments fix
#abe6f2
From: http://www.color-hex.com/

You can do it manually with this command:
`:hi Comment guifg=#ABCDEF` | Where ABCDEF is an appropriate color hex code.

To make it permanent, you will need to add these lines to your `~/.vimrc file` (using green as an example):

```
syntax on
:highlight Comment ctermfg=darkcyan
:highlight Comment ctermfg=lightblue
:highlight Comment ctermfg=#00f7ff
```

Example:
```bash
mkdir -p ~/.vim/colors

```
```
hi clear
if exists("syntax_on")
    syntax reset
endif

let colors_name = "myscheme"

hi Comment  guifg=#80a0ff ctermfg=darkred
```
```bash
cd ~
vim .vimrc
```
```
syntax on
colorscheme myscheme
```

A simple script that fixes vim comments to light blue color on any system:
```bash
cat >lightcomment.sh <<ENDTR
#!/bin/bash
mkdir -p ~/.vim/colors
touch ~/.vim/colors/lightcomment.vim
cat >~/.vim/colors/lightcomment.vim <<EOF
hi clear

if exists("syntax_on")
    syntax reset
endif

let colors_name = "lightcomment"
hi Comment  ctermfg=lightblue
EOF

if [ ! -f ~/.vimrc ]
then
    cat >>~/.vimrc <<EOF
syntax on
colorscheme lightcomment
EOF
else
    echo ".vimrc has been detected. Edit the file manually and add the following lines:"
    echo
    echo "syntax on"
    echo "colorscheme lightcomment"
fi
ENDTR

chmod +x lightcomment.sh
```


---
##### `netstat` How to filter out the unique entries from a netstat output
The netstat file looked like this:
```
  ...
  ...
  TCP    10.137.0.41:61376      10.69.11.238:1433      ESTABLISHED
  TCP    10.137.0.41:61881      10.137.6.230:1433      ESTABLISHED
  TCP    10.137.0.41:61888      10.137.6.230:49154     ESTABLISHED
  ...
  ...
```

To sort we can use `awk`
```bash
awk '{print $3}' 10.137.0.41.ip.log | egrep -o '^[^:]+' | sort -nr | uniq -c
awk '{print $3}' 10.137.0.41.ip.log # Print the 3rd row 10.69.11.238:1433

## Options that we can use with pipe (|)
... | egrep -o '^[^:]+' # pipe through grep filter out the IP untill the collon
... | sort -nr | uniq -c # Speaks for itself
```


---
##### `apt-get`
```bash
# https://www.tecmint.com/useful-basic-commands-of-apt-get-and-apt-cache-for-package-management/

## List All Available Packages
apt-cache pkgnames

## List Installed Packages
apt list --installed

## Search package and related packages
apt-cache search vsftpd

## Check package information
apt-cache show vsftpd

## Show package dependences
apt-cache showpkg vsftpd

## Search for all possible versions of a specific package (example docker-ce)
$ apt-cache madison docker-ce
 docker-ce | 5:18.09.5~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:18.09.4~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 18.06.0~ce~3-0~ubuntu | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 18.03.1~ce~3-0~ubuntu | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages

## Prevent a package from upgrading when apt-get upgrade is run (example docker-ce)
$ apt-mark hold docker-ce

## Remove the hold
apt-mark unhold <package-name>

## Show packages on hold
apt-mark showhold
```


---
##### `dpkg`
```bash
## List Installed on older debian distros
dpkg --get-selections
dpkg --get-selections | grep -v deinstall

## To get a list of a specific package installed:
dpkg --get-selections | grep postgres

## List packeges
dpkg -l
```


---
##### `nmap`
```bash
# Something that REALLY works
# https://security.stackexchange.com/questions/36198/how-to-find-live-hosts-on-my-network
nmap -sP -PS22,3389 target #custom TCP SYN scan

nmap -sP -PA21,22,25,3389 target #21 is used by ftp

sudo nmap -sP -PU161 192.168.2.1/24 #custom UDP scan

#### FIREWALLS
## Test these against a firewall
nmap –v –sA –n www.yourorg.com –oA firewallaudit.log

## Test with fragmented traffic
nmap –sF –g 25 –oN firewallreport.log www.yourorg.com

## Another example
nmap –sS --scan-delay 500 –f –rH firewallreport.txt www.yourorg.com



# https://highon.coffee/blog/nmap-cheat-sheet/
## Ping scans the network, listing machines that respond to ping.
nmap -sP 10.0.0.0/24

## Full TCP port scan using with service version detection
##  usually my first scan, I find T4 more accurate than T5 and still
##  pretty quick.
nmap -p 1-1024 -sV -sS -T4 domain.me

## Prints verbose output, runs stealth syn scan, T4 timing, OS and version
##  detection + traceroute and scripts against target services.
nmap -v -sS -A -T4 target

##  Prints verbose output, runs stealth syn scan, T5 timing, OS and version
##   detection + traceroute and scripts against target services.
nmap -v -sS -A -T5 target

## Prints verbose output, runs stealth syn scan, T5 timing, OS and
##  version detection.
nmap -v -sV -O -sS -T5 target

## Prints verbose output, runs stealth syn scan, T4 timing, OS and version
##  detection + full port range scan.
nmap -v -p 1-65535 -sV -O -sS -T4 target

## Prints verbose output, runs stealth syn scan, T5 timing, OS and
#   version detection + full port range scan.
nmap -v -p 1-65535 -sV -O -sS -T5 target

```


---
##### `curl`
```bash
curl -LI google.com #Follow redirects and get the header only
curl -o website https://google.com #Save output to file
curl -O https://domain.com/file.zip #Download files
```


---
##### Remove/Uninstall `cloudinit`
```bash
[bash]
$ echo 'datasource_list: [ None ]' | tee /etc/cloud/cloud.cfg.d/90_dpkg.cfg
$ apt-get purge cloud-init -y
$ rm -rf /etc/cloud/; rm -rf /var/lib/cloud/
[end]

## Alternative
$ service cloud-init stop
```


---
### LVM
Resize LVM with XFS
```bash
 pvs
 lvs
 vgs
 cat /etc/fstab
 lvextend -l +50%FREE /dev/mapper/centos-var
 vgs
 xfs_growfs /var
 df -h
 vgcfgbackup
```


---
##### Test Disk Read and Write speed
Some examples on disk benchmarking
```bash
## Disk Read/Write speed test with `dd`
sync; dd if=/dev/zero of=/root/testspeed bs=1M count=1024; sync
/sbin/sysctl -w vm.drop_caches=3 ## This cleans the cache from memory
dd if=/root/testspeed of=/dev/null bs=1M count=1024

sync; dd if=/dev/zero of=/efs-infer/bench_infer bs=1M count=1024; sync
/sbin/sysctl -w vm.drop_caches=3
dd if=/efs-infer/bench_infer of=/dev/null bs=1M count=1024

/bin/sync; /bin/dd if=/dev/zero of=/nfs/bulk_benchmark bs=1M count=3072; /bin/sync
/sbin/sysctl -w vm.drop_caches=3
/bin/dd if=/nfs/bulk_benchmark of=/dev/null bs=1M count=3072


sync; dd if=/dev/zero of=/efs bs=1M count=4096000; sync
```


---
##### Disable root login the friendly way
```
no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo 'Please login as the user \"ubuntu\" rather than the user \"root\".';echo;sleep 10" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2Jyv9T14/XraaCUeFZ1xrQsTge9PydO+ypkSdQI4qrnPFJBBBoX0UtxvQYNOaqrxEHQ7wxVrIj7Uwop7D8/DJgJpZHmmHU0PW5uHl7z4m0ofdOdzlx+UyD/n1yh//73E+OhN4x4y+Ann/dkRFqc095kqA6sVZNSbgJPX+iUpB06WjIQXjOYD3Pvy9lXQzghszRt2hWbN8cfYnJ6CLacPfkeGOS/p2wKJ4hkjSr9vfm4MCKDgKIopizMC78tfNxQNkWrxgv78Mg+qgescM83O8CM7uJpflTT+HySutnmR0R+tst4BCdFTV8KsB4ZjNTCkoC5RLRF7FWEt+FmjuPtX/ name@email.com
```


---
##### Ubuntu - Things to do and to install after a fresh Ubuntu install
```bash
apt update && apt upgrade -y
apt install htop nmon nethogs screen vim mc tcpdump net-tools bash-completion
apt install bash-completion
```

Remove `cloud-init` from Ubuntu18
```bash
dpkg-reconfigure cloud-init // Deselect everything except None
```

Remove `clout-init` from Ubuntu newer versions
```bash
## Renmove the application
apt-get purge cloud-init

## Remove the configuration files
mv /etc/cloud/ ~/; sudo mv /var/lib/cloud/ ~/cloud-lib

## Disable the service
systemctl show -p WantedBy network-online.target
```


---
##### CentOS specific stuff
```bash
## Things to do and to install after a fresh CentOS install
# In case there is no networking
[bash]
yum install -y epel-release
yum makecache
yum install vim nano curl wget tcpdump git net-tools bash-completion openssl-devel  bind-utils httpd-tools screen nethogs
[end]

[bash]
vi /etc/susconfig/network-scripts/ifcfg-enp0s3
ONBOOT=yes

yum update -y
yum install -y epel-release
yum install vim nano curl wget tcpdump git net-tools bash-completion openssl-devel  bind-utils httpd-tools screen nethogs

yum install -y openssh
systemctl start sshd.service
systemctl enable sshd.service
[end]


## CentOS7 Static IP
$ vim /etc/sysconfig/network-scripts/ifcfg-IFNAME
IPADDR=192.168.1.200
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=1.0.0.1
DNS2=1.1.1.1
DNS3=8.8.4.4

$ systemctl restart network

## CentOS7 Static Route
$ vim /etc/sysconfig/network-scripts/route-IFNAME
#SOURCE          GW         OPTIONAL
15.15.0.0/24 via 10.1.1.110 dev enp0s3
$ systemctl restart network
```


---
##### Disable/Enable blank passwords in PAM
Source: https://www.cyberciti.biz/tips/linux-or-unix-disable-null-passwords.html

```bash
## For Debian distros
/etc/pam/common-auth  # Authentication settings common to all services
/etc/pam.d/common-password  # Password-related modules common to all services

$ vi /etc/pam/common-auth

## Find out line that read as follows
password required pam_unix.so nullok obscure min=4 max=8 md5

Remove nullok from above line so that it read as follows:
password required pam_unix.so obscure min=4 max=8 md5

## Save the file and exit to shell prompt. Open the next file
$ vim /etc/pam.d/common-password

Find out line that read as follows:
auth required pam_unix.so nullok_secure

Remove nullok_secure from above line so that it read as follows:
auth required pam_unix.so

# Save the file and exit to shell prompt. Now no one be able to login using null password.

## For RedHat based distros
## You need to modify single file /etc/pam.d/system-auth:

vim /etc/pam.d/system-auth

Find out line that read as follows:
auth sufficient /lib/security/pam_unix.so likeauth nullok

Remove nullok from above line so that it read as follows:
auth sufficient /lib/security/pam_unix.so likeauth
```


---
##### When Single User Mode is not working
Single user mode workaroud | http://www.noah.org/wiki/Single_User_Mode

Once you are onto the GRUB menu:

* Select the Kernel line and press `e` to edit. It should look something like this:
`kernel /vmlinuz-2.6.15-27-386 root=/dev/mapper/Ubuntu-root ro quiet splash`

* Replace with:
`kernel /vmlinuz-2.6.15-27-386 root=/dev/mapper/Ubuntu-root ro single`

If prompted with a message:
`Give root password for maintenance (or type Control-D to continue)`

Reboot again and choose a kernel. Eddit the kernel line and make it to look:
`kernel /vmlinuz-2.6.15-27-386 root=/dev/mapper/Ubuntu-root rw init=/bin/bash`

When you get to the shell try editing `/etc/passwd` and `/etc/shadow`. 
Usually I just blank out password field for the `root` user then reboot. This may not work if the PAM was setup to disallow root login. In that case you may need to boot back into single user mode and then update the PAM to allow root login or allow root login without a password. Alternatively, the `passwd` command may be available so you can just run this to actually set a real password.


---
##### Confert Amazon AMI to VMware image
https://serverfault.com/questions/319949/convert-amazon-ami-to-vmware-image

If you still have access to the instance, I believe the simplest way would be using `dd` to copy it off to a raw file (possibly just directly piping over SSH to the destination system like in ssh your.ec2-system `dd if=/dev/sdh bs=1M | gzip' | gunzip | dd of=/tmp/ec2-image.raw`) and then using something like qemu-img to convert the raw image to a VMDK file.

`qemu-img convert -f raw -O vmdk /tmp/ec2-image.raw /tmp/ec2-image.vmdk`
Maybe the QEMU wikibook could be of some further help, if you still are having problems.

```bash
ssh your.ec2-syst.em 'dd if=/dev/sdh bs=1M | gzip' | gunzip | dd of=/tmp/ec2-image.raw

qemu-img convert -f raw -O vmdk /tmp/ec2-image.raw /tmp/ec2-image.vmdk


## https://serverfault.com/questions/364470/how-to-download-private-ubuntu-aws-ec2-ami-for-local-use

## https://preda.wordpress.com/2012/08/29/downloading-an-amazon-ec2-ami-to-local-drive/

## To filetransfer the VM named Nomad
# /dev/xvda
ssh -i privkey.pem ubuntu@10.212.31.158 'sudo dd if=/dev/xvda bs=1M | gzip' | gunzip | dd of=xvda.raw

# /dev/xvdb
ssh -i privkey.pem ubuntu@10.212.31.158 'sudo dd if=/dev/xvdb bs=1M | gzip' | gunzip | dd of=xvdb.raw

# QEMU confert the raw images of Nomad
qemu-img convert -f raw -O vmdk xvda.raw xvda.vmdk
```


---
##### Linux Password Recovery

Mount Remount the /
`mount -o remount,rw /`

Using GRUB to invoke bash | https://wiki.archlinux.org/index.php/Reset_lost_root_password
1. Select the appropriate boot entry in the GRUB menu and press `e` to edit the line.
2. Select the kernel line and press e again to edit it.
3. Append `init=/bin/bash`  .. at the end of line.
4. Press `Ctrl-X` to boot (this change is only temporary and will not be saved to your `menu.lst`). After booting you will be at the bash prompt.

5. Your root file system is mounted as readonly now, so remount it as read/write
`mount -n -o remount,rw /`

6. Use the `passwd` command to create a new root password.
7. Reboot by typing reboot -f and do not lose your password again!


---
##### Boot hangs at: `random nonblocking pool is initialized`
Update the GRUB parameter with:
`GRUB_CMDLINE_LINUX_DEFAULT="nomodeset"`

`vim /etc/default/grub`
.. or
`/etc/init/grub`


---
##### DOCKER
```bash
# Get basic servce information
service docker status
/etc/init.d/docker status
systemctl status docker

# Start stop restart the service
service docker start
/etc/init.d/docker start
systemctl start docker

# Get container IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_name_or_id

# Get docker information
docker info #localy
docker -H 10.76.16.136 info #remotely

# List containers
docker -H 10.76.16.136 ps -a

# List containers but filter by name containing `elabs11`
docker -H 10.76.16.136 ps -a --filter name=elabs11

# Attach to a running container
docker -H 10.76.16.136 exec -it 980cb9f3d526 /bin/bash

# List containers cool format
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.Status}}\t{{.Ports}}"

# List the containers and format using a set of parameters
docker -H 10.69.11.100 ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}
docker -H 10.89.1.242:2375 ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"" --filter name=servicename

# Copy something localy inside a volume of a helper container
docker -H 10.69.11.89:2375 cp logstash/pipeline_us/* container_name:/volume/dir/elk/logstash/pipeline

## Remove all images
docker rmi -f $(docker images -a -q)

## Stop all containers
docker stop $(docker ps -a -q)

## Delete all containers
docker rm -vf $(docker ps -a -q)

## List images from a private docker registry V2
curl -X GET https://myregistry:5000/v2/_catalog

## List all tags from a private docker registry repository
curl -X GET https://myregistry:5000/v2/ubuntu/tags/list
```


---
##### Basic site-to-site VPN with OpenSwan
Example configuration files:
```bash
vim /etc/ipsec.d/myconn1.conf
```
```
conn myconn1
	type=tunnel
	authby=secret
	left=%defaultroute
	leftid=1.2.3.4
	leftnexthop=%defaultroute
	leftsubnet=10.109.128.0/17
	right=5.6.7.8
	rightsubnet=10.16.0.0/16
	esp=aes256-sha1
	keyexchange=ike
	ike=aes256-sha1
	salifetime=3600s
	pfs=yes
	auto=start
	dpddelay=30
	dpdtimeout=120
	dpdaction=hold
```
```bash
vim /etc/ipsec.d/myconn1.secrets
```
```
1.2.3.4 5.6.7.8: PSK "setstrongpskhere"
```
```bash
ipsec auto --rereadsecrets
ipsec auto --add myconn1
ipsec auto --up myconn1
ipsec auto --down

service ipsec restart
ipsec auto --status | grep myconn1
```


---
##### `iptables`

Run the following. It'll insert the rule at the top of your iptables and will allow all traffic unless subsequently handled by another rule.
```bash
iptables -I INPUT -j ACCEPT
```

You can also flush your entire iptables setup with the following:
```bash
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
```

If you flush it, you might want to run something like:
```bash
iptables -A INPUT -i lo -j ACCEPT -m comment --comment "Allow all loopback traffic"
iptables -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT -m comment --comment "Drop all traffic to 127 that doesn't use lo"
iptables -A OUTPUT -j ACCEPT -m comment --comment "Accept all outgoing"
iptables -A INPUT -j ACCEPT -m comment --comment "Accept all incoming"
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT -m comment --comment "Allow all incoming on established connections"
iptables -A INPUT -j REJECT -m comment --comment "Reject all incoming"
iptables -A FORWARD -j REJECT -m comment --comment "Reject all forwarded"
```

If you want to be a bit safer with your traffic, don't use the accept all incoming rule, or remove it with "iptables -D INPUT -j ACCEPT -m comment --comment "Accept all incoming"", and add more specific rules like:
```bash
iptables -I INPUT -p tcp --dport 80 -j ACCEPT -m comment --comment "Allow HTTP"
iptables -I INPUT -p tcp --dport 443 -j ACCEPT -m comment --comment "Allow HTTPS"
iptables -I INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT -m comment --comment "Allow SSH"
iptables -I INPUT -p tcp --dport 8071:8079 -j ACCEPT -m comment --comment "Allow torrents"
```

**NOTE:** They need to be above the 2 reject rules at the bottom, so use I to insert them at the top. Or if you're are like me, use `iptables -nL --line-numbers` to get the line numbers, then use `iptables -I INPUT ...` to insert a rule at a specific line number.

Finally, save your work with:
```bash
iptables-save > /etc/network/iptables.rules #Or wherever your iptables.rules file is

iptables -t nat -L
```


---
##### MYSQL
```bash
## CREATE Database
create database dbname;

## CREATE User
# Only local
CREATE USER 'dbuser'@'localhost' IDENTIFIED BY 'strongpassword';

# Able to access from anywhere
CREATE USER 'dbuser'@'%' IDENTIFIED BY 'strongpassword';

## GRANT Privileges
GRANT ALL PRIVILEGES ON dbname.* TO 'dbuser'@'localhost';
GRANT ALL PRIVILEGES ON dbname.* TO 'dbuser'@'%';

## Commit
flush privileges;
```

Template
```
## CREATE Database
create database linksindexdb;
CREATE USER 'linksindexuser'@'%' IDENTIFIED BY 'strongpassword';
GRANT ALL PRIVILEGES ON linksindexdb.* TO 'linksindexuser'@'%';
flush privileges;

CREATE TABLE sitersslinks (
id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
time VARCHAR(30) NOT NULL,
parrentsite VARCHAR(512) NOT NULL,
rsslink VARCHAR(512) NOT NULL
);
```


---
##### NGINX
```
## Common NGINX headers

## For CORS
add_header Access-Control-Allow-Origin "domain.com";

proxy_set_header        Host                    $http_host;
proxy_set_header        X-Real-IP               $remote_addr;
proxy_set_header        X-Forwarded-For         $proxy_add_x_forwarded_for;
proxy_set_header        X-Forwarded-Proto       $scheme;
proxy_set_header        X-Forwarded-Host        $http_host;
proxy_set_header        X-Forwarded-Port        $remote_port;



## Nginx proxy default example
upstream workers {
        least_conn;
        server 10.20.30.10:8081; #worker01
        server 10.20.30.20:8081; #worker02
        server 10.20.30.30:8081; #worker03
        server 10.20.30.40:8081; #worker04
}

server {
        listen 443 ssl;
        server_name mysite.example.com;

        ssl_certificate     /etc/nginx/ssl-cert.crt;
        ssl_certificate_key /etc/nginx/ssl-cert.key;
        ssl_protocols       TLSv1.2;
        ssl_ciphers         HIGH;
        ssl_stapling on;
        ssl_stapling_verify on;

        location /api/v1/api-docs {
                 return 404;
        }

        location / {
                 proxy_pass http://workers/;
        }

        access_log /var/log/nginx/mysite.example.com.access.log;
        error_log /var/log/nginx/mysite.example.com.error.log;
}
```


---
##### VyOS
VyOS VPN Template
```
set vpn ipsec esp-group esp_settings_1 compression 'disable'
set vpn ipsec esp-group esp_settings_1 lifetime '3600'
set vpn ipsec esp-group esp_settings_1 mode 'tunnel'
set vpn ipsec esp-group esp_settings_1 pfs 'dh-group2'
set vpn ipsec esp-group esp_settings_1 proposal 1 encryption 'aes256'
set vpn ipsec esp-group esp_settings_1 proposal 1 hash 'sha1'

set vpn ipsec ike-group ike_settings_1 ikev2-reauth 'no'
set vpn ipsec ike-group ike_settings_1 key-exchange 'ikev1'
set vpn ipsec ike-group ike_settings_1 lifetime '28800'
set vpn ipsec ike-group ike_settings_1 proposal 1 dh-group '2'
set vpn ipsec ike-group ike_settings_1 proposal 1 encryption 'aes256'
set vpn ipsec ike-group ike_settings_1 proposal 1 hash 'sha1'

set vpn ipsec site-to-site peer 169.61.69.100 authentication id '54.175.242.45'
set vpn ipsec site-to-site peer 169.61.69.100 authentication mode 'pre-shared-secret'
set vpn ipsec site-to-site peer 169.61.69.100 authentication pre-shared-secret '[secret]'
set vpn ip
```


---
##### ELK | Elasticsearch
Check basic cluster info and version
**Note:** If `cluster_uuid` is missing there is no cluster
```bash
curl -XGET 'http://elastic1.stag.project.loc:9200'
{
  "name" : "elastic1.stag.project.loc",
  "cluster_name" : "project-staging",
  "cluster_uuid" : "-ZbHAW4xTUOlOoENNyl_dw",
  "version" : {
    "number" : "7.15.0",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "79d65f6e357953a5b3cbcc5e2c7c21073d89aa29",
    "build_date" : "2021-09-16T03:05:29.143308416Z",
    "build_snapshot" : false,
    "lucene_version" : "8.9.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

Check cluster health (short info)
```bash
curl -XGET 'http://elastic2.stag.project.loc:9200/_cluster/health?pretty'
{
  "cluster_name" : "project-staging",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 3,
  "number_of_data_nodes" : 3,
  "active_primary_shards" : 20,
  "active_shards" : 40,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```

Check cluster state (long command)
```bash
curl -XGET 'http://elastic2.stag.project.loc:9200/_cluster/state?pretty'


### Check the shards allocation
curl -XGET 'http://elastic1.stag.project.loc:9200/_cat/shards?v'
index                                  shard prirep state   docs   store ip         node
.apm-agent-configuration               0     p      STARTED    0    208b 10.0.16.30 elastic1.stag.project.loc
.apm-agent-configuration               0     r      STARTED    0    208b 10.0.16.50 elastic3.stag.project.loc
.kibana_7.15.0_001                     0     r      STARTED   86   2.1mb 10.0.16.30 elastic1.stag.project.loc
.kibana_7.15.0_001                     0     p      STARTED   86   2.1mb 10.0.16.50 elastic3.stag.project.loc
.kibana_task_manager_7.13.3_001        0     r      STARTED   10  66.4kb 10.0.16.51 elastic2.stag.project.loc
.kibana_task_manager_7.13.3_001        0     p      STARTED   10  92.6kb 10.0.16.50 elastic3.stag.project.loc
.kibana_7.13.3_001                     0     p      STARTED   73   2.1mb 10.0.16.51 elastic2.stag.project.loc
.kibana_7.13.3_001                     0     r      STARTED   73   2.1mb 10.0.16.50 elastic3.stag.project.loc
.ds-ilm-history-5-2021.09.10-000003    0     p      STARTED              10.0.16.51 elastic2.stag.project.loc
.ds-ilm-history-5-2021.09.10-000003    0     r      STARTED              10.0.16.50 elastic3.stag.project.loc
...
...
...
```

Explain shard allocation issues (works only if there are shard allocaiton issues i.e. YELLOW or RED cluster state)
```bash
curl -XGET 'http://elastic1.stag.project.loc:9200/_cluster/allocation/explain?pretty'
```


---
##### WORDPRESS
When a wordpress site is hosted with NGINX PROXY -> APACHE -> wordpress | https://stackoverflow.com/questions/37149842/redirect-to-127-0-0-1-when-access-a-wordpress-hosted-with-apache-and-nginx-in-pr

Add the following into `wp-config.php` bellow `WP_HOME` and `WP_SITEURL` (just these two is not enough)
```
define( 'WP_HOME', 'http://mywpsite.domain.com' );
define( 'WP_SITEURL', 'http://mywpsite.domain.com' );
```
```
$_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
```

Also another user mentios adding `ProxyPreserveHost On` to the proxy instance on the apache


---
##### Linux migration - Online Rsync
Migrated:
https://blog.tomspirit.me/2020/05/linux-migration-from-anywhere-to.html


---
##### Linux migration - Offline Rsync
Migrated:
https://blog.tomspirit.me/2020/05/linux-ec2-to-on-premise-migration.html


---
##### Convert a linux manually from AWS to VMware
Migrated:
https://blog.tomspirit.me/2020/05/linux-darkside-migration-aka-dd-over.html



---
### Misc stuff
Regex for IP search/highlighting. Works well with Notepad++ search
`\b(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(?1)){3}\b`