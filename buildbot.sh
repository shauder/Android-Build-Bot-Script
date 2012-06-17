#!/bin/bash

# Shane Faulkner
# http://shanefaulkner.com
# You are free to modify and distribute this code,
# so long as you keep my name and URL in it.
# Thanks Andy and David =D

#----------------------Build Settings--------------------#

# you build source code directory path
SAUCE=/you/source/directory

DATE=`eval date +%m`-`eval date +%d`

# products, seperated by a space, you are building for 
# (product directory name for /out/target/product/)
# must have a matching LunchCMD, BuildNME and OutputNME 
# for each poduct listed, maintaining the same order
PRODUCTS="productOne productTwo productThree"

# the lunch commands you want to use seperated by a space
declare -a LunchCMD=(
'productOne-lunchCMD' 
'productTwo-lunchCMD' 
'productThree-lunchCMD')

# the name of the built rom in the output folder
declare -a BuildNME=(
'productOne-Built-Rom-Name' 
'productTwo-Built-Rom-Name' 
'productThree-Built-Rom-Name')

# new name of rom to be uploaded to cloud service
declare -a OutputNME=(
'productOne-Output-Rom-Name' 
'productTwo-Output-Rom-Name' 
'productThree-Output-Rom-Name')

# number for the -j parameter
J=9

# cloud storage directory
CLOUD=/cloud/storage/directory

#----------------------Build Bot Code--------------------#

cd $SAUCE

repo sync

make clean

for product in $PRODUCTS
do
	ARRAYPOS=0
	source build/envsetup.sh && lunch ${LunchCMD[$ARRAYPOS]} && time make -j$J otapackage
	cp $SAUCE/out/target/product/$product/${BuildNME[$ARRAYPOS]}"-"$DATE".zip" $CLOUD/${OutputNME[$ARRAYPOS]}"-"$DATE".zip"
	let "$ARRAYPOS += 1"
done
