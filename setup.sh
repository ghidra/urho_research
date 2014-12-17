#!/bin/bash

make_alias(){
  #$1 FOLDER $2 LINKEDFOLDER $3 NEWFOLDER
  if [ ! -d $3 ];then
    #link does not exist, we can make it
    ln -s $2 $3
    echo "Created link to" $1 "at" $3
  else
    echo $1 "Folder already exists as" $3
  fi
}

URHOPATH=$1
#first make sure that the given folder is good

if [ -d $URHOPATH ];then

  URHOBINPATH=$URHOPATH"/Bin/"
  URHODATAPATH=$URHOPATH"/Bin/Data/"
  URHOCOREDATAPATH=$URHOPATH"/Bin/CoreData/"

  # Absolute path this script is in, thus /home/user/bin
  SCRIPT=$(readlink -f "$0")
  SCRIPTPATH=$(dirname "$SCRIPT")

  echo "script path:"$SCRIPTPATH
  echo "urho path:"$URHODATAPATH

  for Dir in $(find $SCRIPTPATH* -mindepth 1 -maxdepth 1 -not -path '*/\.*' -type d );
  do
      FOLDER=$(basename $Dir);
      case $FOLDER in
        "Scripts")make_alias $FOLDER $SCRIPTPATH"/"$FOLDER $URHODATAPATH$FOLDER"/research" ;;
        "RenderPaths") make_alias $FOLDER $SCRIPTPATH"/"$FOLDER $URHOCOREDATAPATH$FOLDER"/research" ;;
        "Techniques") make_alias $FOLDER $SCRIPTPATH"/"$FOLDER $URHOCOREDATAPATH$FOLDER"/research" ;;
        "Shaders") make_alias $FOLDER $SCRIPTPATH"/"$FOLDER $URHOCOREDATAPATH$FOLDER"/research" ;;
        "Materials") make_alias $FOLDER $SCRIPTPATH"/"$FOLDER $URHODATAPATH$FOLDER"/research" ;;
        *) echo "no commands for:" $FOLDER ;;
      esac

  done

else
  echo "invalid path given:" $URHOPATH
fi
