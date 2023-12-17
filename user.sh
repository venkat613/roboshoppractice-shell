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
    echo -e " $R error: please run as root user"
else
    echo -e  "$G your are root user"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...$R failed"
    else
        echo -e "$2..$G success"
    fi
}

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disableing nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "disableing nodejs"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "install nodejs"

useradd roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating the user"
else
    echo "already user exits"
fi

mkdir /app &>> $LOGFILE
VALIDATE $? "creating the app"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "installing packages"

cd /app 
VALIDATE $? "into app"

unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "unziping the files"

npm install &>> $LOGFILE
VALIDATE $? "installing the libraiers"

cp /home/centos/roboshoppractice-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "Starting user"

cp /home/centos/roboshoppractice-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB client"

mongo --host 172.31.42.97 </app/schema/user.js &>> $LOGFILE
VALIDATE $? "loading userdata" 


