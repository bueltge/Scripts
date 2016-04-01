#!/usr/bin/env bash

# create backups on /media/frank/Backup1TB/Backup

# force strict variable handling (declaration)
set -u

BACKUP_DIR="/media/frank/Backup1TB/Backup"
CURRENT_WD=`pwd`
CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# check if the backup device is available
if [ ! -d "$BACKUP_DIR" ]
then
	echo "Error: Backup device not found"
	exit 1
fi

if [ ! -d ~/bak ]
then
	echo "Creating ~/bak directory"
	mkdir ~/bak
fi

echo "Building ~/packages.list …"
dpkg --get-selections | awk '!/deinstall|purge|hold/ {print $1}' > ~/bak/packages.list

echo "Building ~/sources.list …"
find /etc/apt/sources.list* -type f -name '*.list' -exec bash -c 'echo -e "\n## $1 ";grep "^[[:space:]]*[^#[:space:]]" ${1}' _ {} \; > ~/bak/sources.list

##
# Backing up /root
#
if [ -d "$BACKUP_DIR/root" ]
then
    echo "Starting backup /root …"
    rsync -a /root/  "$BACKUP_DIR/root/"
else
    echo "Error: Could not backup /root as directory $BACKUP_DIR/root does not exist"
fi

##
# Backing up /var/mysql
#
if [ ! -d "$BACKUP_DIR/mysql" ]
then
    echo "Creating backup directory /mysql …"
    mkdir "$BACKUP_DIR/mysql"
fi

if [ -f "$CURRENT_DIR/mysql_dump.sh" ]
then
    cd "$CURRENT_DIR"
    ./mysql_dump.sh -u root -h localhost "$BACKUP_DIR/mysql"
else
    echo "MySQL dump script is not available. Skipping …"
fi

##
# Backing up /etc
#
if [ -d "$BACKUP_DIR/etc" ]
then
    echo "Starting backup /etc …"
    rsync -a /etc/ "$BACKUP_DIR/etc/"
else
    echo "Error: Could not backup /etc as directory $BACKUP_DIR/etc does not exist"
fi

##
# Backing up /opt
#
if [ -d "$BACKUP_DIR/opt" ]
then
    echo "Starting backup /opt …"
    rsync -a /opt/ "$BACKUP_DIR/opt/"
else
    echo "Error: Could not backup /opt as directory $BACKUP_DIR/opt does not exist"
fi

##
# Backing up /home/frank
#
if [ -d "$BACKUP_DIR/home/frank" ]
then
    echo "Starting backup /home/frank …"
    # CD to /home as there is the .rsync-filter file
    cd /home
    rsync -a --exclude-from='/home/frank/Scripts/.rsync-filter' frank/  "$BACKUP_DIR/home/frank/"
else
    echo "Error: Could not backup /home/frank as directory $BACKUP_DIR/home/frank does not exist"
fi


##
# Backing up /var/www
#
if [ -d "$BACKUP_DIR/var/www" ]
then
    echo "Starting backup /var/www …"
    cd /var/www
    rsync -aF ./ "$BACKUP_DIR/var/www/"
else
    echo "Error: Could not backup /var/www as directory $BACKUP_DIR/var/www does not exist"
fi

cd "$CURRENT_WD"
