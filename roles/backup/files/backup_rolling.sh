#!/bin/bash
BUCKET_NAME="servers.backup"
S3_ENDPOINT="https://s3.fr-par.scw.cloud/"
BACKUP_DIR="/var/backups/rolling"

# Create a dir for each rolling day
THIS_BACKUP_DIR="$BACKUP_DIR/day$(date +%w)"
mkdir -p "$THIS_BACKUP_DIR"

# Folders that need to be gzipped and backuped. Separated by new line or space
# in a file called ugc.list
folders=$(<"$BACKUP_DIR/ugc.list") 

# Dump Mysql
echo "Backing up MySQL ..."
if type mysql >/dev/null 2>&1; then
  mysqldump --single-transaction --routines --default-character-set=utf8 --hex-blob --force --opt --all-databases | gzip --best > $THIS_BACKUP_DIR/db.sql.gz
  echo " - $THIS_BACKUP_DIR/db.sql.gz"
else
  echo " ↳ No MySQL instance, skipping."
fi

echo "Backing up MongoDB ..."
if type mongodump >/dev/null 2>&1; then
  # We need to retrieve the password since mongodump does not use .mongorc.js :sigh:
  MONGODB_PASS=$(grep -oP "(?<=db\.auth\('admin', ').*(?='\);)" /home/debian/.mongoshrc.js)
  mongodump -u admin -p "$MONGODB_PASS" --gzip --archive=$THIS_BACKUP_DIR/db.mongo.gz
  MONGODB_PASS=null # for safety
  echo " - $THIS_BACKUP_DIR/db.mongo.gz"
else
  echo " ↳ No Mongo instance, skipping."
fi

echo "Backing up ugc folders ..."
for folder in $folders; do
  printf " - $folder .. "
  FOLDER_SANE=${folder//\//_}
  if [ "$(find $folder -type f | wc -l)" -gt 0 ]; then
    find $folder -type d -o -size -512M -print0 | xargs -0 tar -cPzvf $THIS_BACKUP_DIR/ugc.$FOLDER_SANE.tar > /dev/null
    echo "→ ugc.$FOLDER_SANE.tar"
  else
    echo "empty, not backing up."
  fi
done

if [ `ls $THIS_BACKUP_DIR | wc -l` -gt 0 ]; then
  # Now make a big archive of the day (but without zipping it, no need to)
  TIMESTAMP=$(date +"%F_%s")
  ARCHIVE="$HOSTNAME.$TIMESTAMP.tar"
  echo "Consolidating latest backups to $ARCHIVE :"
  tar -cPvf $BACKUP_DIR/$ARCHIVE $THIS_BACKUP_DIR

  # Upload to vault with description
  echo "Sending to S3-compatible endpoint"
  echo "$ARCHIVE → $BUCKET_NAME, upload started on $(date)" >> $BACKUP_DIR/log_backup.log
  /usr/local/bin/aws s3 cp $BACKUP_DIR/$ARCHIVE s3://$BUCKET_NAME/$HOSTNAME/$ARCHIVE --endpoint-url=$S3_ENDPOINT 2>&1 >> $BACKUP_DIR/log_backup.log

  # Now remove the local consolidated archive that we don't need
  echo "Removing consolidated archive"
  rm -rf $BACKUP_DIR/$ARCHIVE

  echo "Backed up. Exiting."
else
  rm $THIS_BACKUP_DIR
  echo "Nothing to backup or to upload. Exiting."
fi
