#!/bin/bash

URHOPATH=$1
URHOBINPATH=$URHOPATH"/Bin/"
URHODATAPATH=$URHOPATH"/Bin/Data/"

# Absolute path this script is in, thus /home/user/bin
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

echo "script path:"$SCRIPTPATH
echo "urho path:"$URHODATAPATH


for Dir in $(find $SCRIPTPATH* -mindepth 1 -maxdepth 1 -not -path '*/\.*' -type d );
do
    FOLDER=$(basename $Dir);

    #first we need to check that the link we want to make already exist or not
    if [ "$FOLDER" == "Scripts" ]; then
      #http://stackoverflow.com/questions/59838/check-if-a-directory-exists-in-a-shell-script
      NEWFOLDER=$URHODATAPATH$FOLDER"/research"
      if [ ! -d $NEWFOLDER ];then
        #make the link
        ln -s $SCRIPTPATH"/"$FOLDER $NEWFOLDER
        #echo "copy from:"$SCRIPTPATH"/"$FOLDER
        echo "Create the Script folder:"$NEWFOLDER
      fi
    else
      NEWFOLDER=$URHOBINPATH"Extra/"$FOLDER
      if [ ! -d $NEWFOLDER ];then
        ln -s $SCRIPTPATH"/"$FOLDER $NEWFOLDER
        echo "You want to move the $FOLDER folder:"$NEWFOLDER
      fi
    fi

done
