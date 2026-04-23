source .env

set -e

mkdir -p new_postgres/
chmod 700 new_postgres/

LAST_FOLDER=$(ls -1 physical-backups | sort | tail -n 1)
echo "$LAST_FOLDER"

# cp physical-backups/${LAST_FOLDER}/* new_postgres/

DATA_DIR=new_postgres

BACKUP_FOLDER=physical-backups/${LAST_FOLDER}

tar xf ${BACKUP_FOLDER}/base.tar -C ${DATA_DIR}/
mkdir -p ${DATA_DIR}/pg_wal
tar xf ${BACKUP_FOLDER}/pg_wal.tar -C ${DATA_DIR}/pg_wal

mkdir -p ${DATA_DIR}/pg_tblspc

while IFS=' ' read -r oid path; do
    echo "found tablespace"
    echo oid=${oid}
    echo path=${path}
    NEW_TABLESPACE_FOLDER=new_postgres_tablespaces/${oid}/

    mkdir -p ${NEW_TABLESPACE_FOLDER}
    tar xf ${BACKUP_FOLDER}/${oid}.tar -C ${NEW_TABLESPACE_FOLDER}

    SYMLINK_PATH=${DATA_DIR}/pg_tblspc/${oid}
    rm -f ${SYMLINK_PATH}
    ln -s "$(pwd)/${NEW_TABLESPACE_FOLDER}" "${SYMLINK_PATH}"

done < "${DATA_DIR}/tablespace_map"

rm -f ${DATA_DIR}/tablespace_map
