#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm sdl3

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

echo "Getting app..."
echo "---------------------------------------------------------------"
case "$ARCH" in # they use x64 and arm64 for the zip links
	x86_64)  farch=x64;;
	aarch64) farch=arm64;;
esac
ZIP_LINK=$(wget https://api.github.com/repos/drhelius/Geargrafx/releases -O - \
      | sed 's/[()",{} ]/\n/g' | grep -o -m 1 "https.*ubuntu24.04-$farch.zip")
echo "$ZIP_LINK" | awk -F'/' '{gsub(/^v/, "", $(NF-1)); print $(NF-1); exit}' > ~/version
if ! wget --retry-connrefused --tries=30 "$ZIP_LINK" -O /tmp/app.zip 2>/tmp/download.log; then
	cat /tmp/download.log
	exit 1
fi

mkdir -p ./AppDir/bin
bsdtar -xvf /tmp/app.zip -C ./AppDir/bin
chmod +x ./AppDir/bin/geargrafx
rm -f ./AppDir/bin/README.txt
wget -O ./AppDir/bin/gamecontrollerdb.txt https://raw.githubusercontent.com/mdqinc/SDL_GameControllerDB/master/gamecontrollerdb.txt
