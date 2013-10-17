#!/bin/sh

if [ $# -ne "1" ]
then
  echo "Usage: ./import_packages.sh [testing|stable]"
  exit 1
fi

cd /opt/smart-m3-repo

DISTR=testing

SUBREPO=$1
INCOMING=`pwd`/incoming_${SUBREPO}

echo "Running import on `hostname`"
echo "incoling=${INCOMING}"
echo "= Incoming content is="
ls -la ${INCOMING}

BEFORE=`reprepro list testing`

#
# Make sure we're in the apt/ directory
#
cd $INCOMING
cd ..

echo ${INCOMING}
#
#  See if we found any new packages
#
found=0
for i in $INCOMING/*.changes; do
  if [ -e $i ]; then
    found=`expr $found + 1`
  fi
done


#
#  If we found none then exit
#
if [ "$found" -lt 1 ]; then
   exit
fi


#
#  Now import each new package that we *did* find
#
for i in $INCOMING/*.deb; do

echo $i

  # Import package to 'sarge' distribution.
  reprepro  --ignore=wrongdistribution -C ${SUBREPO}  -Vb . includedeb ${DISTR} $i
	echo $i

  # Delete the referenced files
  sed '1,/Files:/d' $i | sed '/BEGIN PGP SIGNATURE/,$d' \
       | while read MD SIZE SECTION PRIORITY NAME; do
        
      if [ -z "$NAME" ]; then
           continue
      fi

      #
      #  Delete the referenced file
      #
      if [ -f "$INCOMING/$NAME" ]; then
       #   rm "$INCOMING/$NAME"  || exit 1
	echo  "$INCOMING/$NAME"  || exit 1
      fi
  done

  # Finally delete the .changes file itself.
#  rm  $i
done




#
#  Now import each new package that we *did* find
#
for i in $INCOMING/*.changes; do

echo $i

  # Import package to 'sarge' distribution.
  reprepro  --ignore=wrongdistribution  -C ${SUBREPO} -Vb . include ${DISTR} $i
	echo $i

  # Delete the referenced files
  sed '1,/Files:/d' $i | sed '/BEGIN PGP SIGNATURE/,$d' \
       | while read MD SIZE SECTION PRIORITY NAME; do
        
      if [ -z "$NAME" ]; then
           continue
      fi

      #
      #  Delete the referenced file
      #
      if [ -f "$INCOMING/$NAME" ]; then
       #   rm "$INCOMING/$NAME"  || exit 1
	echo  "$INCOMING/$NAME"  || exit 1
      fi
  done

  # Finally delete the .changes file itself.
#  rm  $i
done


echo "RESULT:"
AFTER=`reprepro list testing`

echo "before: ${BEFORE}"
echo " after: ${AFTER}"

