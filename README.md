# mame-rpi400

Building MAME for RPi400  
Heavily based on this work: https://gist.github.com/sonicprod  



Flash image on SDcard, then edit /boot/config.txt and at the end add in the \[all] section

    dtoverlay=disable-wifi,disable-bt



Create a 12GB Partition, another one to fill up the entire SD space, then delete the 12GB one: this is a trick to allow the first partition to be extended only for a part of the space available.

Now boot the raspberry pi, it will ask to confirm the keyboard layout and the user name/password for the login.  
Once this is done, run

    sudo raspi-config 
to some more pesonalization:
- System Options -> Hostname (Here I put mame, you can choose anything you'd like)  
- Interface Options -> SSH -> Yes (to enable ssh)  
- Update  (To update)  

Now type "sudo reboot". SSH will be available after the reboot (if you build I reccomend to build inside a tmux session)
To extend the partiton, you'll have to use fdisk:  

    sudo fdisk /dev/mmcblk0
then list the partitions with 'p', I have:  

    Disk /dev/mmcblk0: 29.12 GiB, 31268536320 bytes, 61071360 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x3e6f85cf
    
    Device         Boot    Start      End  Sectors  Size Id Type
    /dev/mmcblk0p1         16384  1064959  1048576  512M  c W95 FAT32 (LBA)
    /dev/mmcblk0p2       ==1064960==  6307839  5242880  2.5G 83 Linux
    /dev/mmcblk0p3      30883840 61071359 30187520 14.4G  f W95 Ext'd (LBA)
    /dev/mmcblk0p5      30885888 61071359 30185472 14.4G  c W95 FAT32 (LBA)

Now write down the start sector for the second partition (1064960), press 'd' to delete a partition, put '2' to delete the secon one  
Then press 'n' to create a new one that will be at its place but with larger size, type 'p' to create a primary partition and '2' for its number, now it's time to type the number saved earlier (1064960), then press return for automatic end sector, and a last 'n' not to remove the signature of the partition just created  
The last command is 'w' to write the partition table on the SD  
Now it's time to resize the file system with the command:  

    sudo resize2fs /dev/mmcblk0p2


I've slightly changed the script to instlall SDL2 because the original would download SDL3 which is not supported.  
Plus for the script to install mame I replaced any hard coded reference to /home/pi to ~ so it will work with any username selected during the raspberry pi set-up  
These can be found in the /script foder in this repo  



