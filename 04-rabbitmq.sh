#!bin/bash

source ./common.sh

check_root

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "adding rabbitmq "

dnf install erlang rabbitmq-server -y &>> $log_file
validate $? "installing RabbitMQ"

systemctl enable rabbitmq-server &>> $log_file
systemctl start rabbitmq-server &>> $log_file
validate $? "Enable & Start Rabbit MQ"

rabbitmqctl list_users | grep -qw "roboshop"
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>> $log_file
    validate $? "creating user for RabbitMQ"
else
    echo  -e "$(timestamp) [INFO] RabbitMQ user aleady exists ...${Y}SKIPPING${N}"

fi    

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validate $? "setting permissions for RabbitMQ"

total_time