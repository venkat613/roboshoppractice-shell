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

VALIDATE $? "disable nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enable nodejs"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "install nodejs"

useradd roboshop
if [ $? -ne 0]
then
    useradd roboshop
    VALIDATE $? "creation of roboshop"
else
    echo -e " $G already roboshop user exits"
fi

mkdir /app
VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

cd /app 

VALIDATE $? "inside app directory"

unzip -o /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "unzip the files"

npm install
VALIDATE $? "installing depencies"

cp /home/centos/roboshoppractice-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying the library"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue daemon reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting catalogue"

cp /home/centos/roboshoppractice-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB client"

mongo --host 172.31.42.97 </app/schema/catalogue.js
VALIDATE $? "loading the data"