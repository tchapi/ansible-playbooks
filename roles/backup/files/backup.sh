#!/bin/sh

# Home root directory
# HOME_DIR=""

BACKUP_DIR="$HOME_DIR/backup"

# Some credentials for mysql/maria_db
# SHOW DATABASES
# SELECT
# LOCK TABLES
# RELOAD
MYSQL_USER="backup"
MYSQL_PASSWORD="password"

# Folders to ignore and patterns to ignore
IGNORE_FOLDERS="(mantis|public|photo)"
IGNORE_PATTERNS="(rel\-|prod|beta)"

# Create a backup folder for each run
TIMESTAMP=$(date +"%F")
THIS_BACKUP_DIR="$BACKUP_DIR/$TIMESTAMP"
mkdir "$THIS_BACKUP_DIR"

BACKED_UP="NO"

MYSQL=`type mysql >/dev/null 2>&1 && echo "ok" || echo "nok"`
if [ "$MYSQL" = "ok" ]; then

  mkdir "$THIS_BACKUP_DIR/mysql" 

  # Retrieves all databases
  databases=`mysql --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema)"`
   
  # Dumps everything
  for db in $databases; do
    mysqldump --single-transaction --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$THIS_BACKUP_DIR/mysql/$db.gz"
  done

  BACKED_UP="YES"

fi

# Retrieves all folders to backup
folders=`ls -d $HOME_DIR/www/*/*/ | grep -Ev '$IGNORE_FOLDERS' | grep -Ev '\w\/$IGNORE_PATTERNS'`
  
if [ `echo "$var" | wc -l` -gt 0 ]; then

  # if folders length > 0...
  mkdir "$THIS_BACKUP_DIR/ugc" 

  # Backup files
  for folder in $folders; do tar -cf $THIS_BACKUP_DIR/ugc/$folder.tar $folder; done

  BACKED_UP="YES"

fi

# Update the "last" symlink
if [ "$BACKED_UP" = "YES "]; then
  ln -sfn "$THIS_BACKUP_DIR" "$BACKUP_DIR/last"
fi

# Syncs last backup with a FTP if any
# TODO
