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
 
dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "mysql-server installation"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "enabling mysql"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "starting mysql"

mysql -h db.ganeshsiripuram.tech -u root -pExpenseApp@1 -e "show databases;" &>>$LOG_FILE
if [ $? -ne 0 ]
    then
    echo "mysql root passowrd is not setup,setting now" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
    VALIDATE $? "setting root password"
    else
    echo "mysql root passowrd is already setup  $Y SKIPPING $N" | tee -a $LOG_FILE
fi