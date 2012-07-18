#!/bin/bash

# Shane Faulkner
# http://shanefaulkner.com
# You are free to modify and distribute this code,
# so long as you keep my name and URL in it.

#---------------------Build Settings------------------#

# your build source code directory path
SAUCE=/home/shauder/TBParadigm

# generate an MD5
MD5=y

# should they be uploaded to dropbox?
CLOUD=y

# cloud storage directory (can be non-cloud storage folder)
CLOUDDIR=/cloud/storage/directory

# number for the -j parameter
J=9

# here goes the roms you would like to build
PRODUCT[0]="toro"			# phone model name (product folder name)
LUNCHCMD[0]="bamf_nexus-userdebug"	# lunch command used for ROM
BUILDNME[0]="bamf_nexus"		# name of the output ROM in the out folder, before "-ota-"
OUTPUTNME[0]="bamf_nexus-toro"		# what you want the new name to be

PRODUCT[1]="maguro"
LUNCHCMD[1]="bamf_maguronexus-userdebug"
BUILDNME[1]="bamf_maguronexus"
OUTPUTNME[1]="bamf_nexus-maguro"

PRODUCT[2]="toroplus"
LUNCHCMD[2]="bamf_nexus_spr-userdebug"
BUILDNME[2]="bamf_nexus_spr"
OUTPUTNME[2]="bamf_nexus-torospr"

# leave alone
DATE=`eval date +%m`-`eval date +%d`

#----------------------FTP Settings--------------------#

# set "FTP=y" if you want to enable FTP uploading
FTP=n

# FTP server settings
FTPHOST[0]="host"	# ftp hostname
FTPUSER[0]="user"	# ftp username 
FTPPASS[0]="password"	# ftp password
FTPDIR[0]="directory"	# ftp upload directory

FTPHOST[1]="host"
FTPUSER[1]="user"
FTPPASS[1]="password"
FTPDIR[1]="directory"

#---------------------Build Bot Code-------------------#


echo -n "Moving to source directory..."
cd $SAUCE
echo "done!"

echo -n "Syncing repositories..."
repo sync
echo "done!"

make clean

for VAL in "${!PRODUCT[@]}"
do
	echo -n "Starting build..."
	source build/envsetup.sh && lunch ${LUNCHCMD[$VAL]} && time make -j$J otapackage
	echo "done!"

	if [ $MD5 = "y" ]; then
		echo -n "Generating MD5..."
		md5sum $SAUCE/out/target/product/${PRODUCT[$VAL]}/${BUILDNME[$VAL]}"-ota-"$DATE".zip" | sed 's|'$SAUCE'/out/target/product/'${PRODUCT[$VAL]}'/||g' > $SAUCE/out/target/product/${PRODUCT[$VAL]}/${BUILDNME[$VAL]}"-ota-"$DATE".md5sum.txt"
		echo "done!"
	fi

	if  [ $CLOUD = "y" ]; then
		echo -n "Moving to cloud storage directory..."
		cp $SAUCE/out/target/product/${PRODUCT[$VAL]}/${BUILDNME[$VAL]}"-ota-"$DATE".zip" $CLOUDDIR/${OUTPUTNME[$VAL]}"-"$DATE".zip"
		if [ $MD5 = "y" ]; then
			cp $SAUCE/out/target/product/toro/${BUILDNME[$VAL]}"-ota-"$DATE".md5sum.txt" $CLOUDDIR/${BUILDNME[$VAL]}"-ota-"$DATE".md5sum.txt"
		fi
		echo "done!"
	fi

done

#----------------------FTP Upload Code--------------------#

if  [ $FTP = "y" ]; then
	echo "Initiating FTP connection..."

	cd $CLOUDDIR
	ATTACH=`for file in *"-"$DATE".zip"; do echo -n -e "put ${file}\n"; done`
if [ $MD5 = "y" ]; then	
	ATTACHMD5=`for file in *"-"$DATE".md5sum.txt"; do echo -n -e "put ${file}\n"; done`
fi

for VAL in "${!FTPHOST[@]}"
do
	echo -e "\nConnecting to ${FTPHOST[$VAL]} with user ${FTPUSER[$VAL]}..."
	ftp -nv <<EOF
	open ${FTPHOST[$VAL]}
	user ${FTPUSER[$VAL]} ${FTPPASS[$VAL]}
	tick
	cd ${FTPDIR[$VAL]}
	$ATTACH
if [ $MD5 = "y" ]; then
	$ATTACHMD5
fi
	quit
EOF
done

	echo -e  "FTP transfer complete! \n"
fi

echo "Done building!"
