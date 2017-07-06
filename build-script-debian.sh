#!/usr/bin/env bash

WORKDIR=${WORKDIR-"livecdtmp-bsdb"}
FILENAME=${FILENAME-"debian-live-8.5.0-amd64-gnome-desktop.iso"}
IMAGE_NAME=${IMAGE_NAME-"balaswecha-live-8.5.0-amd64-gnome-desktop.iso"}

if [ -d $WORKDIR ]; then
  sudo rm -rf $WORKDIR
fi
mkdir -p $WORKDIR
cd $WORKDIR
wget --no-verbose http://iso.morphic/$FILENAME
mkdir mnt
sudo mount -o loop $FILENAME mnt
echo "Mounting Loop Done"
mkdir extract-cd
sudo rsync --exclude=/live/filesystem.squashfs -a mnt/ extract-cd
sudo unsquashfs mnt/live/filesystem.squashfs
echo "Unsquashing Done"
sudo umount mnt
echo "Unmounted iso"
sudo mv squashfs-root edit
sudo cp ../customization-script-debian.sh edit/
sudo cp ../firefox-addon-installer.sh edit/

sudo cp /etc/resolv.conf edit/etc/
sudo mount --bind /dev/ edit/dev
echo "Entering chroot"

sudo chroot edit /bin/bash /customization-script-debian.sh
echo "Exitting chroot"
sudo umount -lf edit/dev
sudo chmod +w extract-cd/live/filesystem.manifest
sudo chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee extract-cd/live/filesystem.packages
echo "Done writing into manifest file"
sudo cp extract-cd/live/filesystem.packages extract-cd/live/filesystem.packages-desktop
sudo sed -i '/ubiquity/d' extract-cd/live/filesystem.packages-desktop
sudo sed -i '/live/d' extract-cd/live/filesystem.packages-desktop
sudo mksquashfs edit extract-cd/live/filesystem.squashfs -comp xz -e edit/boot
echo "mksquashfs Done"
sudo sh -c 'printf $(du -sx --block-size=1 edit | cut -f1) > extract-cd/live/filesystem.size'
cd extract-cd
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt
echo "Starting ISO creation"
sudo genisoimage -rational-rock -volid "BalaSwecha Live" -cache-inodes -joliet -full-iso9660-filenames -b isolinux/isolinux.bin -c isolinux/boot.cat -no- emul-boot -boot-load-size 4 -boot-info-table -output ../$IMAGE_NAME .
echo "Done"
