#!/bin/bash
#Requires Bash 4 or newer
#Requires units command: http://linux.die.net/man/1/units

#$1 --- target directory
#$2 --- count of blocks
#$3 --- block size

declare -A CHECK_SUMS

TEMPDIR=$(mktemp -d dsktest.XXXX)

echo "Creating $2 blocks of size $3..."
for i in $(seq 1 $2)
do
	echo $i
	BLOCKFILE=$(mktemp --tmpdir=$TEMPDIR block.$i.XXXX)
	dd if=/dev/urandom of=$BLOCKFILE bs="$3" count=1
	chmod 666 $BLOCKFILE
	BASENAME=$(basename $BLOCKFILE)
	TARGET_NAME="$1/$BASENAME"
	touch $TARGET_NAME
	chmod 666 $TARGET_NAME
	CHECKSUM=$(cat $BLOCKFILE | tee $TARGET_NAME | md5sum | awk '{print $1}')
	echo $BASENAME
	echo "Block $i created in $TARGET_NAME with checksum $CHECKSUM"
	CHECK_SUMS[$BASENAME]=$CHECKSUM
done

PASSED=1
echo "Checking checksums..."
for BASENAME in "${!CHECK_SUMS[@]}"
do 
	EXPECTED_CHECKSUM=${CHECK_SUMS[$BASENAME]}
	ACTUAL_CHECKSUM=$(md5sum "$1/$BASENAME" | awk '{print $1}')
	if [ $EXPECTED_CHECKSUM == $ACTUAL_CHECKSUM ]
	then
		echo "$BASENAME -- OK"
	else
		echo "$BASENAME -- checksum mismatch! Actual checksum: $ACTUAL_CHECKSUM"
		PASSED=0
	fi
done

if [ $PASSED -eq 1 ]
then
	echo "Check passed!"
else
	echo "Check failed!"
	exit 3
fi

#rm -rf $TEMPDIR
