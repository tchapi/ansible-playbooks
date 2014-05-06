#!/bin/sh

# Home root directory
# HOME_DIR=""

BACKUP_DIR="$HOME_DIR/backup"

# Some credentials for mysql/maria_db
# SHOW DATABASES
# SELECT
# LOCK TABLES
# RELOAD
MYSQL_USER='backup'

# Folders to ignore and patterns to ignore
IGNORE_FOLDERS="(mantis|public|photo)"
IGNORE_PATTERNS="(rel\-|prod|beta)"

# Create a backup folder for each run
TIMESTAMP=$(date +"%F_%s")
THIS_BACKUP_DIR="$BACKUP_DIR/$TIMESTAMP"
mkdir "$THIS_BACKUP_DIR"

BACKED_UP="NO"

MYSQL=`type mysql >/dev/null 2>&1 && echo "ok" || echo "nok"`
if [ "$MYSQL" = "ok" ]; then

  # Retrieves all databases
  databases=`mysql --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema)"`
  
  if [ `echo "$databases" | wc -l` -gt 2 ]; then

    echo "Backing up databases :"
    mkdir "$THIS_BACKUP_DIR/mysql" 

    # Dumps everything
    for db in $databases; do
      ([  "$db" = "mysql" ] || [ "$db" = "performance_schema" ]) && continue
      echo -ne " - $db .."
      mysqldump --single-transaction --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$THIS_BACKUP_DIR/mysql/$db.gz"
      echo "done."
    done

    BACKED_UP="YES"

  fi

fi

folders_count=`find $HOME_DIR/www/ -type d | wc -l`

if [ "$folders_count" -gt 1 ]; then # ./ counts as one ...

  # Retrieves all folders to backup
  folders=`ls -d $HOME_DIR/www/*/*/ | grep -Ev '$IGNORE_FOLDERS' | grep -Ev '\w\/$IGNORE_PATTERNS'`

  if [ `echo "$folders" | wc -l` -gt 0 ]; then

    # if folders length > 0...
    echo "Backing up ugc folders :"
    mkdir "$THIS_BACKUP_DIR/ugc" 

    # Backup files
    for folder in $folders; do 
      echo -ne " - $folder .."
      mkdir $THIS_BACKUP_DIR/ugc/$(basename $(dirname $folder))
      tar -cPf $THIS_BACKUP_DIR/ugc/$(basename $(dirname $folder))/$(basename $folder).tar $folder;
      echo "done."
    done

    BACKED_UP="YES"

  fi

fi

# Update the "last" symlink
if [ "$BACKED_UP" = "YES" ]; then
  ln -sfn "$THIS_BACKUP_DIR" "$BACKUP_DIR/last"
else
  rmdir "$THIS_BACKUP_DIR"
fi

# Syncs last backup with a FTP if any
# TODO
