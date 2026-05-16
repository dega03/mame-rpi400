#!/bin/bash

# This script build the latest SDL2 version without X11 dependency.

function sdl2-latest {
  CHECKURL=https://github.com/libsdl-org/SDL/releases/latest
  HTMLTAG='<title>Release '

  LATESTSDL2VER=$(wget -q -O - $CHECKURL | grep "$HTMLTAG" | awk '{print $2}')

  if [ -z $LATESTSDL2VER ]; then echo ERROR; exit; fi   # We make sure wget was successful

  echo $LATESTSDL2VER
  }

function sdl2-ttf-latest {
  CHECKURL=https://github.com/libsdl-org/SDL_ttf/releases/latest
  HTMLTAG='<title>Release '

  LATESTSDL2TTFVER=$(wget -q -O - $CHECKURL | grep "$HTMLTAG" | awk '{print $2}')

  if [ -z $LATESTSDL2TTFVER ]; then echo ERROR; exit; fi   # We make sure wget was successful

  echo $LATESTSDL2TTFVER
  }

#VERSION=$(sdl2-latest)
#TTFVERSION=$(sdl2-ttf-latest)

VERSION="2.32.10"
TTFVERSION="2.24.0"

if [ "$(sdl2-config --version)" == "$VERSION" ]; then
  echo SDL2 is already at the latest version \($VERSION\).
  exit
else
  if [ "${1,,}" != "nodep" ]; then
    echo Installing SDL2 dependencies...
    sudo apt-get install libfreetype6-dev libdrm-dev libgbm-dev libudev-dev libdbus-1-dev libpulse-dev libasound2-dev liblzma-dev libjpeg-dev libtiff-dev libwebp-dev autoconf automake libtool pkg-config pulseaudio pulseaudio-utils libpulse0 -y
    echo OpenGL ES 2 dependencies...
    sudo apt-get install libgles2-mesa-dev -y
  fi
  echo Build dependencies...
  sudo apt-get install build-essential -y
  cd ~
  echo Buiding SDL2 $VERSION...
  # Based from "Compile SDL2 from source"
  # https://github.com/midwan/amiberry/wiki/Compile-SDL2-from-source
  wget https://libsdl.org/release/SDL2-${VERSION}.zip
  unzip SDL2-${VERSION}.zip
  rm SDL2-${VERSION}.zip
  cd SDL2-${VERSION}
  ./autogen.sh
  ./configure --disable-video-opengl --disable-video-opengles1 --disable-video-x11 --disable-esd --disable-video-wayland --disable-video-rpi --disable-video-vulkan --enable-video-kmsdrm --enable-video-opengles2 --enable-alsa --enable-pulseaudio --disable-pulseaudio-shared --disable-joystick-virtual --enable-arm-neon --enable-arm-simd

  [ $(uname -m) == "armv7l" ] && make -j $(nproc) CFLAGS='-mtune=cortex-a72 -mfpu=neon-fp-armv8 -mfloat-abi=hard'
  [ $(uname -m) == "aarch64" ] && make -j $(nproc) CFLAGS='-mcpu=cortex-a72'

  sudo make install

  # SDL2_ttf
  wget https://libsdl.org/projects/SDL_ttf/release/SDL2_ttf-${TTFVERSION}.tar.gz
  tar zxvf SDL2_ttf-${TTFVERSION}.tar.gz
  rm SDL2_ttf-${TTFVERSION}.tar.gz
  cd SDL2_ttf-${TTFVERSION}
  ./configure
  make -j $(nproc)
  sudo make install
  sudo ldconfig -v

  cd ~
  sudo rm -R SDL2-${VERSION}
  # sudo rm -R SDL2_ttf-${TTFVERSION}  # No need, it's inside the SDL2 folder just deleted
  sudo apt-get remove build-essential -y
  
  # Preparing to set SDL2 default audio driver settings
  LINE='SDL_AUDIODRIVER=pulseaudio'
  FILE='/etc/environment'
  # Check for default SDL2 audio driver, and set it not present
  if grep -qxF "$LINE" "$FILE"; then
    echo "Entry '$LINE' already present in $FILE"
  else
    # Setting variable for this session and saving it in environment setting
    SDL_AUDIODRIVER=pulseaudio
    sudo echo "$LINE" | sudo tee -a "$FILE" > /dev/null
    echo "Added: $LINE"
  fi
fi
