#!/bin/bash

BACKUP_DIR="$0"

# Create a backup folder for each run
TIMESTAMP=$(date +"%F_%s")

# FTP Stuff
HOSTNAME=`hostname`
FTP_HOST="dedibackup-dc2.online.net"

# Colors
green="\033[32m"
cyan="\033[36m"
yellow="\033[33m"
reset="\033[0m"

if [ -d $BACKUP_DIR ]; then  

  FOLDER=$(basename "$THIS_BACKUP_DIR")
  FOLDER=$FOLDER"-"$TIMESTAMP

  echo -e "${cyan}Backuping to FTP${reset} :"
  ftp $FTP_HOST <<EOF
  binary
  passive
  cd "$HOSTNAME"
  put "| tar -cPvf - $THIS_BACKUP_DIR" $FOLDER.tar
  quit
EOF
  echo -e "${green}Backed up${reset}. Exiting."
  logger -p cron.info "Directory backed up to $FTP_HOST"

else
  echo -e "${yellow}Directory does not exist${reset}. Exiting."
fi
