#!bin/bash
user_id=$(id -u)
log_folder="/var/log/shell_practice"
log_file="${log_folder}/${0}.log"
domain_name="jsrgroup.online"
scripts_dir=$(dirname "$(realpath "$0")")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ] ; then
    echo "Run this with SUDO access"
    exit 1
fi

mkdir -p $log_folder
echo  "script started ececution at $(date +"%F %T")"

timestamp(){
 date +"%F %T"
}

validate (){
    if [ $1 -ne 0 ] ; then
    echo  -e "$(timestamp) [ERROR] ${2} ...${R}FAILED${N}" | tee -a $log_file
    exit 1
else
    echo  -e "$(timestamp) [INFO] ${2} .. ${G}SUCCUSS${N}" | tee -a $log_file
fi
}

 
echo "$(timestamp) [INFO]   =====Script Started Execution ====" | tee -a $log_file

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

echo "$(timestamp) Script completed in: $SECONDS seconds"
echo "$(timestamp) [INFO]   =====Script Completed Execution ====" | tee -a $log_file
