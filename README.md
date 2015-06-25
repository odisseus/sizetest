# sizetest
An utility to check whether a file system (e. g. a SD card) does indeed have the declared storage capacity.

It writes random data files to the file system and checks whether the checksums of resulting files are correct. 
If any file is corrupt, its checksum will almost certainly be wrong.

If the storage device actually has less capacity than declared, and if the amount of written data exceeds the real capacity, 
some of the dayta will necessarily get overwritten. This will cause checksum mismatches.
The failed check does not necessarily mean that the reported capacity is false, but it is a strong hint.

**WARNING**: This script may **CORRUPT DATA**, especially if the storage device declares false size. 
It is best to use this script on an empty storage device.

##Usage
```bash
dsktest.sh /directory/at/your/device <count-of-files> <file-size>
```
`count-of-files` -- number of random data files to write to directory. 

`file-size` -- the size of each file. Same unit suffixes are supported as in the dd utility.

Total amount of data should not exceed the amount of free space available on the file system as per its declaration.

Example:
```bash
#Write 60 1GiB files to my 64 GB MicroSD card
dsktest.sh /media/MICROSD_64_GB 60 1G
```


##Credits
Inspired by description of FakeFlashTest tool found here: http://www.rmprepusb.com/tutorials/-fake-usb-flash-memory-drives
