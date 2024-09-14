#!bin/bash

LOG_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log" 
mkdir -p $LOG_FOLDER
 
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R please run the script using the root privilages $N" | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is $R not successful $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is $G  successful $N" | tee -a $LOG_FILE
    fi
}

echo "script started running at : $(date)"

CHECK_ROOT

dnf install nginx -y
VALIDATE $? "installing nginx"

systemctl enable nginx
VALIDATE $? "enabling nginx"

systemctl start nginx
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/*

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "downloading code"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip
VALIDATE $? "unzipping code"

systemctl restart nginx