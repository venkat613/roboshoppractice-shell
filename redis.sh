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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? "installing the remis"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "enableing redis"

dnf install redis -y &>> $LOGFILE
VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf

VALIDATE $? "connecting to remote ip"

systemctl enable redis &>> $LOGFILE
VALIDATE $? "enable redis"

systemctl start redis &>> $LOGFILE
VALIDATE $? "start redis"
