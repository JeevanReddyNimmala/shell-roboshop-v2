#!bin/bash

source ./common.sh

check_root

dnf module enable mysql:8.4 -y &>> $log_file
dnf install mysql-server -y &>> $log_file
validate $? "mysql-server installation"

systemctl enable mysqld
systemctl start mysqld
validate $? "mysql-server enable and start"

mysql_secure_installation --set-root-pass RoboShop@1
validate $? "setting username and password"



total_time
