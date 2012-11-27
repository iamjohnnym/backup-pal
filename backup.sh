#!/usr/bin/env bash

#####################################################################
#             Basic website and database backup script              #
#   
#
#
#

##### SET VARIABLE DECLARATIONS #####

DOMAINS_ROOT='~/'
MAX_BACKUPS=3
DATE=$(date "+%Y-%m-%d")
DB_STAMP=dbdaily.backup.${DATE}
SITE_STAMP=sitedaily.backup.${DATE}
BACKUP_DIR=~/backups
TMP=tmp
DB_DIR=dbfiles
SITE_DIR=sitefiles
TMP_PATH=${BACKUP_DIR}/${TMP}
DB_PATH=${BACKUP_DIR}/${DB_DIR}
SITE_PATH=${BACKUP_DIR}/${SITE_DIR}

validate_dir()
{
    # Set up directory paths
    if [ ! -d ${BACKUP_DIR} ]; then
        mkdir -p ${BACKUP_DIR}/{${TMP},${DB_DIR},${SITE_DIR}}
    elif [ ! -d ${TMP_PATH} ]; then
        mkdir -p ${TMP_PATH}
    elif [ ! -d ${DB_PATH} ]; then
        mkdir -p ${DB_PATH}
    elif [ ! -d ${SITE_PATH} ]; then
        mkdir -p ${SITE_PATH}
    fi
    sleep 1
}

database_backup()
{
    # Get a list of databases for the database user
    $(mysql -e "show databases;" > ${TMP_PATH}/tmpdbs)
    
    # Remove first line in the file
    $(perl -p -i -e 's:Database::;' ${TMP_PATH}/tmpdbs)
    $(perl -p -i -e 's:information_schema::;' ${TMP_PATH}/tmpdbs)

    # Make a dump of each database
    for x in $(cat ${TMP_PATH}/tmpdbs); do
        $(mysqldump --add-drop-table ${x} > ${DB_PATH}/${STAMP}.${DATE}.sql)
    done
}

domain_backup()
{
    # 
}

validate_dir

database_backup
