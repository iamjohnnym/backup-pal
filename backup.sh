#!/usr/bin/env bash

#####################################################################
#             Basic website and database backup script              #
#   
#
#
#

##### SET VARIABLE DECLARATIONS #####

DOMAINS_ROOT=~/
MAX_BACKUPS=3
DATE=$(date "+%Y-%m-%d")
DB_STAMP=dbdaily.backup
SITE_STAMP=sitedaily.backup
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
        # Dump the database
        $(mysqldump --add-drop-table ${x} > ${DB_PATH}/${DB_STAMP}.${x}.${DATE}.sql)
        # Tar.gz the .sql file
        $(tar pczfP ${DB_PATH}/${DB_STAMP}.${x}.${DATE}.sql.tar.gz ${DB_PATH}/${DB_STAMP}.${x}.${DATE}.sql)
        # Remove .sql file
        $(rm ${DB_PATH}/${DB_STAMP}.${x}.${DATE}.sql)
    done
}

domain_backup()
{
    # .tar the files in the domain_list
    for x in $(cat domain_list); do
       $(tar pczfP ${SITE_PATH}/${SITE_STAMP}.${x}.${DATE}.tar.gz ${DOMAINS_ROOT}/${x})
    done
}

validate_dir

database_backup

domain_backup
