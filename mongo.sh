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
    echo -e  " $R error :: $N please run as root user"
else
    echo -e "$G your root user"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...$R failed"
    else
        echo -e "$2 ...$G success"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying the repo"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "installing the mongodb"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enableing the mongodb"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "starting the mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "changing the ip"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "restarting the mongod"


