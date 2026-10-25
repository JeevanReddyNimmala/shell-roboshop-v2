#!bin/bash

#!bin/bash
#!bin/bash
app_name=shipping
source ./common.sh

check_root

app_setup
java_setup
systemd_setup



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


restart
total_time
