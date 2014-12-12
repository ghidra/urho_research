#!/bin/bash

URHOPATH=$1
URHODATA=$URHOPATH"/Bin/Data/"

# Absolute path this script is in, thus /home/user/bin
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

echo $SCRIPTPATH
echo $URHODATA


for Dir in $(find $SCRIPTPATH* -mindepth 1 -maxdepth 1 -not -path '*/\.*' -type d );
do
    FOLDER=$(basename $Dir);
    if [ "$FOLDER" == "Scripts" ]; then
	     echo "Want to move the script folder"
    else
	     echo "You want to move the $FOLDER folder"
    fi

done
