# sizetest
An utility to check whether a file system (e. g. a SD card) does indeed have the declared storage capacity.

It writes random data files to the file system and checks whether the checksums of resulting files are correct. 
If any file is corrupt, its checksum will almost certainly be wrong.

If the storage device actually has less capacity than declared, and if the amount of written data exceeds the real capacity, 
some of the dayta will necessarily get overwritten. This will cause checksum mismatches.
The failed check does not necessarily mean that the reported capacity is false, but it is a strong hint.

**WARNING**: This script may **CORRUPT DATA**, especially if the storage device declares false size. 
It is best to use this script on an empty storage device.
