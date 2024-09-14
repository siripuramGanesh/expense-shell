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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installing nodejs"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
    then 
        echo -e "expense is not there going to $G create $N it"
        useradd expense
        VALIDATE $? "creating expense user"
    else 
        echo -e "user is already created $Y SKIPPING $N"
fi



mkdir -p /app 
VALIDATE $? "creating new directory"


curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading backend file"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "unzipping backend  file"

cd /app

npm install &>>$LOG_FILE
VALIDATE $? "installing npm"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "insralling mysql"