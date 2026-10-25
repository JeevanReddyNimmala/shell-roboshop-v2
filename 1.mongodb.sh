#!bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "adding mango repo"

dnf install mongodb-org -y &>> $log_file
validate $? "installing MongoDb" 

systemctl enable mongod &>> $log_file
systemctl start mongod &>> $log_file
validate $? "enable and start MongoDb"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
validate $? "chnaging the ip to 0.0.0.0"

systemctl restart mongod 
validate $? "mongodb restart"

total_time