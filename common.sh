#!bin/bash
user_id=$(id -u)
log_folder="/var/log/roboshop"
log_file="${log_folder}/${0}.log"
scripts_dir=$(dirname "$(realpath "$0")")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

check_root(){
if [ $user_id -ne 0 ] ; then
    echo "Run this with SUDO access"
    exit 1
fi
    mkdir -p $log_folder
    echo  "script started ececution at $(date +"%F %T")"
}

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

nodejs_setup(){
    dnf module disable nodejs -y &>> $log_file
    validate $? "Disable nodejs"

    dnf module enable nodejs:24 -y &>> $log_file
    validate $? "Enable nodejs"

    dnf install nodejs -y
    validate $? "Install nodejs" &>> $log_file 

    npm install &>> $log_file
    validate $? "Installing dependencies"
}

java_setup(){
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

    mvn clean package &>> $log_file
    validate $? "Installing de pendencies"

    mv target/shipping.jar shipping.jar &>> $log_file
    validate $? "moving shipping.jar file"
}

python_setup(){
    dnf install python3.14 python3.14-pip -y &>> $log_file
    validate $? "Python 3.14 installation"


    cd /app
    python3.14 -m venv /app/.venv
    validate $? "Creating virtual environment"
    /app/.venv/bin/pip install -r requirements.txt
    validate $? "insatalling dependencies"
}

app_setup(){
        id roboshop &>> $log_file
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        validate $? "creating user for $app_name"
    else
        echo  -e "$(timestamp) [INFO] $app_name user aleady exists ...${Y}SKIPPING${N}"

    fi 
    rm -rf /app
    mkdir -p /app
    validate $? "Creating App directory"

    curl -L -o "/tmp/$app_name.zip" https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/"$app_name-v4.zip"
    validate $? "downloading the $app_name"

    cd /app
    unzip /tmp/"$app_name.zip"
    validate $? "unziping the application"

}

systemd_setup(){

    sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/"$app_name.service""
    cp "$scripts_dir/"$app_name.service"" /etc/systemd/system/"$app_name.service"

    systemctl daemon-reload &>> $log_file
    validate $? "daemon reloaded"
    systemctl enable $app_name &>> $log_file
    validate $? "Enabled the $app_name"
    systemctl start $app_name &>> $log_file
    validate $? "Stated $app_name"
}

restart(){
    systemctl restart $app_name
    validate $? "Restarting $app_name"
}

total_time()
{
    echo "$(timestamp) Script completed in: $SECONDS seconds"
    echo "$(timestamp) [INFO]   =====Script Completed Execution ====" | tee -a $log_file
}
