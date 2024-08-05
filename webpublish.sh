#!/bin/bash

PATH1C=/opt/1cv8/x86_64/current
PATHSITE='/var/www/test.local'
CLUSTER1C=gw
#1c wsap's dir
WSAP=/etc/apache2/1c


if [ -z "$1" ]; then
	echo Must specify the database name:
	read tmpname
	dbname=$tmpname
else
	dbname=$1
fi
	alias2a=$( echo $dbname | md5sum | head -c 12 )
	tmpfl=$(mktemp)
	$PATH1C/webinst -publish -apache24 -wsdir $alias2a -dir $PATHSITE/$dbname -connstr "Srvr=$CLUSTER1C;Ref=$dbname" -confpath $tmpfl
	sed -E '/Load|^\s*$/d' $tmpfl > $WSAP/$dbname.wsap
	rm $tmpfl
if [ $? -eq 0 ]; then
	echo Database has been published
fi

while true; do
	read -p "Enable http services? (y/n)" yn
    case $yn in
        [Yy] ) echo Http services enabled;
		if [ -z "$(grep "httpServices" $PATHSITE/$dbname/default.vrd)" ];then
			sed -i '/ws point/a\\t<httpServices publishExtensionsByDefault="true">\n\t</httpServices>' $PATHSITE/$dbname/default.vrd
				while true; do
					read -p "Enable sync? (y/n)" yn

				    case $yn in
					[Yy] ) echo Sync enabled;
						if [ -z "$(grep "<point name" $PATHSITE/$dbname/default.vrd)" ];then
							sed -i '/ws /r wsseg.txt' $PATHSITE/$dbname/default.vrd
						fi
						if [ -z "$(grep "<service name" $PATHSITE/$dbname/default.vrd)" ];then
							sed -i '/<http/r httpseg.txt' $PATHSITE/$dbname/default.vrd
						fi
					       break;;
					[Nn] ) echo Without changes;
					       exit;;
				       *) echo invalid arguments;;
				    esac
				done
		fi
	       break;;
        [Nn] ) echo Without changes;
	       exit;;
       *) echo invalid arguments;;
    esac
done


exit 0
#while getopts h:s: flag
#do
#	case "${flag}" in
#		h) httpservice=${OPTARG};;
#		s) sync=${OPTARG};;
#	esac
#done
exit 0

