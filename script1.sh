#!/bin/bash

#you need to go into folder with your kali iso first
#I need to add scripted check for kali iso in current folder
#also need to check for usb device automatically...
#for now iso and usb device names are hardcoded
dd if="./kali2023all.iso" of=/dev/sdb bs=64k status=progress

echo 'done copying kali iso onto pendrive'
echo 'now making additional partition'

#I had 32GB disk and somehow sometime before I decided 16GB is okay
#I don't remember why
partition_start='16GB'

parted -a optimal /dev/sdb mkpart primary "$partition_start" 100%

parted /dev/sdb print

echo 'additional partition added, encrypting...'

#change password to something more secure... Shouldn't be hardcoded but it is for now.
#I will have to work on returning some random passwords as option
printf 'password123' | cryptsetup -q luksFormat /dev/sdb3 -

echo 'encrypted partition should be in place'

printf 'password123' | cryptsetup luksOpen /dev/sdb3 kali_persistence

mkfs.ext4 -L persistence /dev/mapper/kali_persistence

echo 'encrypted partition formatted'

mount /dev/mapper/kali_persistence /mnt

echo 'encrypted partition mounted'

#you need that persistence file even though there is barely anything inside
#but it is important, so keep that file inside your script and iso folder
cp ./persistence.conf /mnt/

printf "\n"
printf "\n"
ls -alF /mnt/
cat /mnt/persistence.conf

printf "\n"
echo 'look into above output to see if persistence.conf was copied to pendrive'

umount /mnt
 
cryptsetup luksClose /dev/mapper/kali_persistence

echo 'all unmounted, close, all done'
