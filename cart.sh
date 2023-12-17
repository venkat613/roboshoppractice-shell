#!/bin/bash
ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%s)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
if [ $ID -ne 0 ]
then 
    echo -e " $R error :: kindly run as root user"
else
    echo -e " $G your root user"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e " $2 ... $R failed"
    else
        echo -e "$2...$G success"
    fi
}

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disable the nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enable the nodejs"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "install the nodejs"

useradd roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating the user"
else
    echo "already user exits"
fi

mkdir /app
VALIDATE $? "into app directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "downloadthe zip file"

cd /app 
VALIDATE $? "into app"

unzip /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "unzip the files"

npm install &>> $LOGFILE
VALIDATE $? "install dependies"

cp /home/centos/roboshoppractice/cart.service /etc/systemd/system/cart.service
VALIDATE $? "copying the data"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reload"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "Enable cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "Starting cart"






