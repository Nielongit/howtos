#!/bin/bash
##Bash script to check tar files and send email
####
####Variables
####
TO_EMAIL=test@test.email.com
LOGDATE=$(date +%F-%H%M%S);
EMAIL=/usr/bin/nail
ETO=lcudnekar@netechgoa.co.in
BKPLIB=/opt/script/bkplib.cfg
HOSTN=$(hostname)
####
####End Variables
####
#######Run Script

function sndEmail() {
#   echo "Email - $2"
   EDATE=$(echo -e "$(date +%d-%m-%Y-%H:%M:%S)\n ")
   MAILRC=/dev/null from=$TO_EMAIL smtp=192.168.5.102 $EMAIL -s "$1 $EDATE." $ETO <<< "Date:$EDATE$2"
   if ! [ "$?" = "0" ]; then
        echo "Error while sending email. Return value:$?" >> /opt/script/testt
   fi
}

chktarinteg() {
	echo "########"
        echo "Oracle Tar"
	TARDIR=$1
	#LS=$(ls -p $TARDIR  | grep -v /)
	LS=$(find $TARDIR -name *tar.Z)
	for USER in $LS
	do
		echo "####$USER####"
		tar tzf $USER > /dev/null
		if ! [ "$?" = "0" ]; then
        		echo "Tar.Gzip $USER is corrupt"
		else
			echo "Tar.Gzip $USER is ok"	
   		fi
	done
}

#Check partion /srv where backup files are present
bkpdiskspace() {
	echo "########"
	echo "Partition"
	df -h | grep srv
	echo "########"
	echo "Oracle"
	du -sh /srv/backup/dbsvr/oracle/*
	echo "########"
}

#User has to input the tar location
TAR_LOC=$1
retoutp=$(bkpdiskspace $TAR_LOC)
echo -e "$retoutp"
retoutp1=$(chktarinteg $TAR_LOC)
echo -e "$retoutp1"
sndEmail "Disk Usage on backup server $HOSTN - $LOGDATE" "$retoutp $retoutp1"

