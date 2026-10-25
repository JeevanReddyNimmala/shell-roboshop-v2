#!bin/bash

app_name=payment
source ./common.sh

check_root




dnf module disable nginx -y &>> $log_file
validate $? "disable nginx"
dnf module enable nginx:1.26 -y &>> $log_file
validate $? "enable nginx version:1.26"
dnf install nginx -y &>> $log_file
validate $? "nginx installation"

systemctl enable nginx &>> $log_file
validate $? "enable nginx "
systemctl start nginx &>> $log_file
validate $? "Start/re-start nginx"

rm -rf /usr/share/nginx/html/* &>> $log_file
validate $? "removing default nginx config"


curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>> $log_file
validate $? "downloading fornt end code"
cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $log_file
validate $? "unzipping fornt end code"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/roboshop.conf"
cp "$scripts_dir/roboshop.conf" /etc/systemd/system/roboshop.conf
validate $? "validate copied roboshop config"

nginx -t &>> $log_file
validate $? "validate nginx configuration"
systemctl restart nginx &>> $log_file
validate $? "Start/Restart nginx"
#dnf install python3.14 python3.14-pip -y &>> $log_file

timestamp
