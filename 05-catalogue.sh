#!bin/bash

app_name=catalogue

source ./common.sh

check_root

app_setup

nodejs_setup


systemd_setup



cp "$scripts_dir/mongo.repo" /etc/yum.repos.d/mongo.repo
validate $? "aDDINIG MONGODB"

dnf install mongodb-mongosh -y
validate $? "Installing the mongodb client"

product_count=$(mongosh --host "mongodb.$domain_name" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()') 2>> $log_file
validate $? "Connecting to mongodb"
if [ "$product_count" -eq 0 ] ; then
         
    validate $? "loading the data"
else
    echo -e "$(timesamp)[INFO] Products are already loaded ${Y}SKIPPING${N}"
fi    

restart

total_time



