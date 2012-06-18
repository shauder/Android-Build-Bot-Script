#!/bin/bash

# Shane Faulkner
# http://shanefaulkner.com
# You are free to modify and distribute this code,
# so long as you keep my name and URL in it.
# Thanks Andy and David =D

#---------------------Build Settings------------------#

# your build source code directory path
SAUCE=/your/source/directory

# cloud storage directory (can be non-cloud storage folder)
CLOUD=/cloud/storage/directory

# number for the -j parameter
J=9

# leave alone
DATE=`eval date +%m`-`eval date +%d`

# here goes the roms you would like to build
PRODUCT[0]="toro"
LUNCHCMD[0]="bamf_nexus-userdebug"
BUILDNME[0]="bamf_nexus"
OUTPUTNME[0]="bamf_nexus-toro"

PRODUCT[1]="maguro"
LUNCHCMD[1]="bamf_maguronexus-userdebug"
BUILDNME[1]="bamf_maguronexus"
OUTPUTNME[1]="bamf_nexus-maguro"

PRODUCT[2]="torospr"
LUNCHCMD[2]="bamf_nexus_spr-userdebug"
BUILDNME[2]="bamf_nexus_spr"
OUTPUTNME[2]="bamf_nexus-torospr"

#----------------------FTP Settings--------------------#

# set "FTP=y" if you want to enable FTP uploading
FTP=y

# FTP server settings
FTPHOST[0]="host"
FTPUSER[0]="user"
FTPPASS[0]="password"
FTPDIR[0]="directory"

FTPHOST[1]="host"
FTPUSER[1]="user"
FTPPASS[1]="password"
FTPDIR[1]="directory"

#---------------------Build Bot Code-------------------#

cd $SAUCE

repo sync

make clean

for VAL in "${!PRODUCT[@]}"
do
	source build/envsetup.sh && lunch ${LUNCHCMD[$VAL]} && time make -j$J otapackage
	cp $SAUCE/out/target/product/${PRODUCT[$VAL]}/${BUILDNME[$VAL]}"-ota-"$DATE".zip" $CLOUD/${OUTPUTNME[$VAL]}"-"$DATE".zip"
done

#----------------------FTP Upload Code--------------------#

if  [ $FTP = "y" ]; then
	echo "Initiating FTP connection..."

	cd $CLOUD
	ATTACH=`for file in *"-"$DATE".zip"; do echo -n -e "put ${file}\n"; done`

	for VAL in "${!FTPHOST[@]}"
	do
		echo -e "\nConnecting to ${FTPHOST[$VAL]} with user ${FTPUSER[$VAL]}..."
		ftp -nv <<EOF
		open ${FTPHOST[$VAL]}
		user ${FTPUSER[$VAL]} ${FTPPASS[$VAL]}
		cd ${FTPDIR[$VAL]}
		$ATTACH
		quit
	EOF
	done

	echo -e  "FTP transfer complete! \n"
fi
