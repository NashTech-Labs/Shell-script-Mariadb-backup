#!/bin/bash
set -ex
apt update
apt install wget
apt install default-mysql-client -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --update

sleep 5

bash -x ./env.sh
backup_filename="mariadbbackup_"$(date +"%d.%m.%y-%H-%M-%S")
echo -e "\nBacking Up ..."
mysqldump -h ${DB_HOST} -P ${DB_PORT} -u ${DB_ADMIN_USER} -p ${DBPASSWORD} -A --opt --column-statistics=0  > ${backup_filename}
if [[ $? != 0 ]]
then
    echo "Exiting......"
    exit
fi
sleep 10
echo -e "\nFinished Backup"
tar -czf ${backup_filename}".tar.gz" ${backup_filename}

aws s3 cp ./${backup_filename}".tar.gz" ${BUCKET_NAME}