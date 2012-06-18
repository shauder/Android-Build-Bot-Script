bAndroid-Build-Bot-Script
========================

A bash script that can be used to automatically build and upload Android ROMS to a cloud service for sharing.

If you are running this script from SSH you may need to replace the "repo sync" command with:

exec ssh-agent bash
ssh-add
repo sync
