#!bin/bash

source ./common.sh

check_root


dnf module disable redis -y
dnf module enable redis:7 -y
dnf install redis -y &>> $log_file
validate $? "install redis"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validate $? "allowing remote connections"

systemctl enable redis &>> $log_file
systemctl start redis &>> $log_file
validate $? "Enable and start redis"


timestamp()
