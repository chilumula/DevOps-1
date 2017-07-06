#!/usr/bin/env bash

WORKDIR=${WORKDIR-"Hero"}
FILENAME=${FILENAME-"ubuntu-14.04.4-desktop-amd64.iso"}
IMAGE_NAME=${IMAGE_NAME-"Hero.iso"}

if [ -d $WORKDIR ]; then
  sudo rm -rf $WORKDIR
fi
mkdir -p $WORKDIR
echo "directory created"
cd $WORKDIR
echo "changed Directory"
cp /home/sai/Downloads/$FILENAME /home/sai/Music
echo "copied the file"
mkdir mnt
echo "created the directory mnt"
sudo mount -o loop $FILENAME mnt
echo "Mounting Loop Done"
mkdir extract-cd
echo "extracted"
sudo rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd
echo "unsquash on"
sudo unsquashfs mnt/casper/filesystem.squashfs
echo "Unsquashing Done"
sudo umount mnt
echo "Unmounted iso"
sudo mv squashfs-root edit
sudo cp ../customization-script.sh edit/
sudo cp -f ../assets/lsb-release edit/etc/
sudo rm -rf edit/usr/share/ubiquity-slideshow/slides
sudo cp -rf ../assets/ubiquity-slides edit/usr/share/ubiquity-slideshow/slides
echo "done with adding the ubiquity-slides"
sudo cp -f ../assets/plymouth/ubuntu_logo.png edit/lib/plymouth/
sudo cp -f ../assets/plymouth/themes/text.plymouth edit/etc/alternatives/
sudo cp -f ../assets/plymouth/themes/ubuntu-logo/* edit/lib/plymouth/themes/ubuntu-logo/
sudo cp -f ../assets/plymouth/themes/ubuntu-text/* edit/lib/plymouth/themes/ubuntu-text/
sudo rm -f edit/usr/share/unity-greeter/logo.png
echo "removed logo.png from the old file"
sudo cp /etc/resolv.conf edit/etc/

sudo mount --bind /dev/ edit/dev
echo "Entering chroot"

sudo chroot edit /bin/bash /customization-script.sh
echo "Exitting chroot"
sudo rm -f edit/customization-script.sh
sudo rm -f edit/firefox-addon-installer.sh
sudo umount -lf edit/dev
sudo chmod +w extract-cd/casper/filesystem.manifest
sudo chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee extract-cd/casper/filesystem.manifest
echo "Done writing into manifest file"
sudo cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop
sudo mksquashfs edit extract-cd/casper/filesystem.squashfs -comp xz -e edit/boot
echo "mksquashfs Done"
sudo sh -c 'printf $(du -sx --block-size=1 edit | cut -f1) > extract-cd/casper/filesystem.size'
cd extract-cd
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt
echo "Starting ISO creation"
sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "../$IMAGE_NAME" .
echo "Done"
