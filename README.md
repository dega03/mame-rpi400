# mame-rpi400

Building MAME for RPi400  
Heavily based on this work: https://gist.github.com/sonicprod  



Flash image on SDcard, then edit /boot/config.txt and at the end add in the \[all] section:

    dtoverlay=disable-wifi,disable-bt

Then open /boot/cmdline.txt and remove "resize" from there, so the partition will not be resized and we can extend later the partition by of how much we like.

Now instert the SD on the Raspberry pi and follow the instructions to create the user with password.
Then log-in and run 
  
    sudo raspi-config
      -> System Options -> Hostname -> mame (or anything you'd like)
                           Auto Login -> Yes (to make life easier)
      -> Interface Options -> SSH -> Yes (to enable it)
      -> Update
    -> Finish
    hostname -I   (to see current IP to be used to connect with SSH)

Then you can download my sript folder (will be easier fro a ssh terminal, so you can copy-paste) by running:

    mkdir scripts
    cd scripts
    wget https://raw.githubusercontent.com/dega03/mame-rpi400/refs/heads/main/scripts/resize_root.sh
    wget https://raw.githubusercontent.com/dega03/mame-rpi400/refs/heads/main/scripts/sdl2-install.sh
    wget https://raw.githubusercontent.com/dega03/mame-rpi400/refs/heads/main/scripts/mame-updater.sh
    chmod +x *
    cd ..

then you can run them one by one:

    sudo ./scripts/resize_root.sh
    ./scripts/sdl2-install.sh
    ./scripts/mame-updater.sh latest
   

I've slightly changed the script to instlall SDL2 because the original would download SDL3 which is not supported.  
Plus for the script to install mame I replaced any hard coded reference to /home/pi to ~ so it will work with any username selected during the raspberry pi set-up  
These can be found in the /script foder in this repo  



