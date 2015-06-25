#!/bin/bash
#Requires Bash 4 or newer
#Requires units command: http://linux.die.net/man/1/units

#$1 --- target directory
#$2 --- count of blocks
#$3 --- block size

declare -A CHECK_SUMS

echo "Creating $2 blocks of size $3..."
for i in $(seq 1 $2)
do
	echo $i
	BLOCKFILE=$(mktemp --tmpdir="$1" block.$i.XXXX)
	CHECKSUM=$(dd if=/dev/urandom bs="$3" count=1 | tee $BLOCKFILE | md5sum | awk '{print $1}')
	echo "Block $i created in $BLOCKFILE with checksum $CHECKSUM"
	CHECK_SUMS[$BLOCKFILE]=$CHECKSUM
done

PASSED=1
echo "Checking checksums..."
for FILENAME in "${!CHECK_SUMS[@]}"
do 
	EXPECTED_CHECKSUM=${CHECK_SUMS[$FILENAME]}
	ACTUAL_CHECKSUM=$(md5sum "$FILENAME" | awk '{print $1}')
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

