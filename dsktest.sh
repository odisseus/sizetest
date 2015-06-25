#!/bin/bash
#Requires Bash 4 or newer

#$1 --- target directory
#$2 --- count of blocks
#$3 --- block size, format as recognized by dd command

function log_to_stderr(){
	>&2 echo $@
}

function check_checksums(){
	local PASSED=1
	for FILENAME in "${!CHECK_SUMS[@]}"
	do 
		EXPECTED_CHECKSUM=${CHECK_SUMS[$FILENAME]}
		ACTUAL_CHECKSUM=$(md5sum "$FILENAME" | awk '{print $1}')
		if [ $EXPECTED_CHECKSUM == $ACTUAL_CHECKSUM ]
		then
			log_to_stderr "$FILENAME -- OK"
		else
			log_to_stderr "$FILENAME -- checksum mismatch! Actual checksum: $ACTUAL_CHECKSUM"
			PASSED=0
		fi
	done
	echo $PASSED
}

declare -A CHECK_SUMS

log_to_stderr "Creating $2 blocks of size $3..."
CHECK_STOP=1
CHECK_FAILED=0
for i in $(seq 1 $2)
do
	log_to_stderr $i
	BLOCKFILE=$(mktemp --tmpdir="$1" block.$i.XXXX)
	CHECKSUM=$(dd if=/dev/urandom bs="$3" count=1 | tee $BLOCKFILE | md5sum | awk '{print $1}')
	log_to_stderr "Block $i created in $BLOCKFILE with checksum $CHECKSUM"
	CHECK_SUMS[$BLOCKFILE]=$CHECKSUM
	if [ $i -eq $CHECK_STOP ]
	then
		log_to_stderr "Checking checksums for the first $i blocks so far..."
		if [ $(check_checksums) == 1 ]
		then
			log_to_stderr "Check passed!"
		else
			log_to_stderr "Check failed!"
			CHECK_FAILED=1
			break
		fi
		CHECK_STOP=$(( $CHECK_STOP * 2 ))
	fi
done

log_to_stderr "Checking checksums after writing all the blocks..."

if [ $(check_checksums) == 1 ]
then
	log_to_stderr "Check passed!"
else
	log_to_stderr "Check failed!"
	CHECK_FAILED=1
fi

log_to_stderr "Removing files..."
for FILENAME in "${!CHECK_SUMS[@]}"
do 
	rm -f $FILENAME
done

exit($CHECK_FAILED)

