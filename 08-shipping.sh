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

dnf module enable maven:3.9 -y &>> $log_file
validate $? "Enable Java"
dnf install maven java-25-openjdk-devel -y &>> $log_file
validate $? "Install Java"
alternatives --set  java "/usr/lib/jvm/java-25-openjdk/bin/java" &>> $log_file
validate $? "Setting Java 25 as default version for installing and usage"

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME

validate $? "setting JAVA_Home for maven"

id roboshop &>> $log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating user for Shipping"
else
    echo  -e "$(timestamp) [INFO]  User aleady exists ...${Y}SKIPPING${N}"

fi 

rm -rf /app
mkdir -p /app
validate $? "Creating App directory"

curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip &>> $log_file
validate $? "downloading the Shipping"

cd /app
unzip /tmp/shipping.zip &>> $log_file

validate $? "unziping the Shipping"

cd /app
mvn clean package &>> $log_file
validate $? "Installing de pendencies"

mv target/shipping.jar shipping.jar &>> $log_file
validate $? "moving shipping.jar file"


sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/shipping.service"
cp "$scripts_dir/shipping.service" /etc/systemd/system/shipping.service

dnf install mysql -y &>> $log_file
validate $? "Insatlling mysql client"

count=$(mysql -h "mysql.$domain_name" -u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;" 2>> $log_file)

if [ -z "$count"] || [ "$count" -eq 0 ] ; then 
    mysql -h mysql.$domain_name -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $log_file
    validate $? "loading shipping data"
    
else
    echo -e "$(timestamp)[INFO] Master Data already loaded ... ${Y}SKIPPING${N}"
fi
#sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/shippinig.service"
#cp "$scripts_dir/shipping.service" /etc/systemd/system/shipping.service

mysql -h mysql.$domain_name -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $log_file
    validate $? "loading user data"

systemctl daemon-reload &>> $log_file
systemctl enable shipping &>> $log_file
validate $? "enabled shipping"
systemctl start shipping &>> $log_file
validate $? "Start Shipping"

systemctl restart shipping &>> $log_file
validate $? "Re-Started Shipping"

echo "$(timestamp) Script completed in: $SECONDS seconds"
echo "$(timestamp) [INFO]   =====Script Completed Execution ====" | tee -a $log_file
