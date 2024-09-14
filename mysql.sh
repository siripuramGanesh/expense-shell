#!bin/bash

LOG_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOG_FOLDER/$SCRITNAME-$TIMESTAMP.log" 
mkdir -p $LOG_FOLDER
 
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "$R please run the script using root privilages $N" | tee -a $LOG_FILE
        exit 1
    fi
}

CHECK_ROOT

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo "$2 is $G successful $N" | tee -a $LOG_FILE
    else
        echo "$2 is $R not successful $N" | tee -a $LOG_FILE
    fi
}

echo "script started running at : $(date)"

dnf install mysql-server -y
VALIDATE $? "mysql-server installation"

systemctl enable mysqld
VALIDATE $? "enabling mysql"

systemctl start mysqld
VALIDATE $? "starting mysql"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "setting root password"
