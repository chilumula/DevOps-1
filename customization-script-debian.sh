mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts

export HOME=/etc/skel

YOUTUBE_EXTENSION_URL=${YOUTUBE_EXTENSION_URL-"https://addons.mozilla.org/firefox/downloads/latest/463677/addon-463677-latest.xpi"}

dbus-uuidgen >/etc/machine-id 

# Install Packages
sed -i -e 's/main/main contrib non-free/g' /etc/apt/sources.list
echo "deb https://dl.bintray.com/balaswecha/balaswecha-dev jessie main" > /etc/apt/sources.list.d/balaswecha.list
apt-get update
apt-get install -y openjdk-7-jre pepperflashplugin-nonfree
#Remove it - licensing conflicts
update-pepperflashplugin-nonfree --install
apt-get install -y openshot audacity artha shutter tuxtype tuxpaint kazam calibre freemind gimp inkscape vlc ibus-m17n firefox

# install pencilbox and skin packages 
apt-get install -y --force-yes pencilbox balaswecha-sync #balaswecha-skin

# adding youtube extension in firefox
# sudo bash /firefox-addon-installer.sh $YOUTUBE_EXTENSION_URL

apt-get clean

###### Branding Changes ########

# Regenerate default Schemas
#glib-compile-schemas /usr/share/glib-2.0/schemas

umount /proc || sudo umount -lf /proc
umount -lf /sys
umount -lf /dev/pts
