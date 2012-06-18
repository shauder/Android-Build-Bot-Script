#!/bin/bash

# Shane Faulkner
# http://shanefaulkner.com
# You are free to modify and distribute this code,
# so long as you keep my name and URL in it.
# Thanks Andy and David =D

#---------------------Build Settings------------------#

# your build source code directory path
SAUCE=/your/source/directory

DATE=`eval date +%m`-`eval date +%d`

# products, seperated by a space, you are building for 
# (product directory name for /out/target/product/)
# must have a matching LunchCMD, BuildNME and OutputNME 
# for each poduct listed, maintaining the same order
PRODUCT[0]="productOne"
PRODUCT[1]="productTwo"
PRODUCT[2]="productThree"

# the lunch commands you want to use seperated by a space
LunchCMD[0]="productOne-lunchCMD"
LunchCMD[1]="productTwo-lunchCMD"
LunchCMD[2]="productThree-lunchCMD"

# the name of the built rom in the output folder
BuildNME[0]="productOne-Built-Rom-Name"
BuildNME[1]="productTwo-Built-Rom-Name"
BuildNME[2]="productThree-Built-Rom-Name"

# new name of rom to be uploaded to cloud service
OutputNME[0]="productOne-Output-Rom-Name"
OutputNME[0]="productTwo-Output-Rom-Name" 
OutputNME[0]="productThree-Output-Rom-Name"

# number for the -j parameter
J=9

# cloud storage directory
CLOUD=/cloud/storage/directory

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
	source build/envsetup.sh && lunch ${LunchCMD[$VAL]} && time make -j$J otapackage
	cp $SAUCE/out/target/product/${PRODUCT[$VAL]}/${BuildNME[$VAL]}"-ota-"$DATE".zip" $CLOUD/${OutputNME[$VAL]}"-"$DATE".zip"
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
		tick
		cd ${FTPDIR[$VAL]}
		$ATTACH
		quit
	EOF
	done

	echo -e  "FTP transfer complete! \n"
fi
