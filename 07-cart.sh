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
    validate $? "creating user for Cart"
else
    echo  -e "$(timestamp) [INFO]  User aleady exists ...${Y}SKIPPING${N}"

fi 
rm -rf /app
mkdir -p /app
validate $? "Creating App directory"

curl -L -o /tmp/cart.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/cart-v4.zip
validate $? "downloading the cart"

cd /app
unzip /tmp/cart.zip
validate $? "unziping the cart application"

cd /app
npm install &>> $log_file
validate $? "Installing dependencies"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/cart.service"
cp "$scripts_dir/cart.service" /etc/systemd/system/cart.service

systemctl daemon-reload &>> $log_file
validate $? "daemon reloaded"
systemctl enable cart &>> $log_file
validate $? "Enabled the cart"
systemctl start cart &>> $log_file
validate $? "Stated cart"



echo "$(timestamp) Script completed in: $SECONDS seconds"
echo "$(timestamp) [INFO]   =====Script Completed Execution ====" | tee -a $log_file
