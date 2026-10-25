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

dnf module disable nodejs -y &>> $log_file
validate $? "Disable nodejs"

dnf module enable nodejs:24 -y &>> $log_file
validate $? "Enable nodejs"

dnf install nodejs -y
validate $? "Install nodejs" &>> $log_file

id roboshop &>> $log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating user for User"
else
    echo  -e "$(timestamp) [INFO]  User aleady exists ...${Y}SKIPPING${N}"

fi 
rm -rf /app
mkdir -p /app
validate $? "Creating App directory"

curl -L -o /tmp/user.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/user-v4.zip
validate $? "downloading the user"

cd /app
unzip /tmp/user.zip
validate $? "unziping the user application"

cd /app
npm install &>> $log_file
validate $? "Installing dependencies"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/user.service"
cp "$scripts_dir/user.service" /etc/systemd/system/user.service

systemctl daemon-reload &>> $log_file
validate $? "daemon reloaded"
systemctl enable user &>> $log_file
validate $? "Enabled the user"
systemctl start user &>> $log_file
validate $? "Stated user"



echo "$(timestamp) Script completed in: $SECONDS seconds"
echo "$(timestamp) [INFO]   =====Script Completed Execution ====" | tee -a $log_file
