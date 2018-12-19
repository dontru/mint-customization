#!/bin/bash

ISO=$(ls -p | grep -v / | grep -F .iso | grep iso$ -m 1)

if [[ -z "$ISO" ]]; then
  echo "Couldn't find iso file in the current directory"
  exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root"
  exit 2
fi

sudo apt install -y squashfs-tools genisoimage

mkdir livecdtmp
mv $ISO livecdtmp
cd livecdtmp

mkdir mnt
sudo mount -o loop $ISO mnt

mkdir extract-cd
sudo rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd

sudo unsquashfs mnt/casper/filesystem.squashfs
sudo mv squashfs-root edit

sudo cp /etc/resolv.conf edit/etc/
sudo mount --bind /dev/ edit/dev

mkdir edit/mydir
chmod -R 777 edit/mydir

(
cd ..
contents=$(ls -p | grep -E -v "^livecdtmp/$|^build.sh$")
cp -r $contents livecdtmp/edit/mydir/
)

cat << EOF > edit/mydir/chroot.sh
#!/bin/bash

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts

export HOME=/root
export LC_ALL=C

dbus-uuidgen > /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

cd /mydir

if [[ -f config.sh ]]; then
  . config.sh
fi

rm -r /mydir
aptitude clean
rm -rf /tmp/* ~/.bash_history

rm /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

umount /proc || umount -lf /proc
umount /sys
umount /dev/pts
exit
EOF

chmod -R 777 edit/mydir
sudo chroot edit ./mydir/chroot.sh

sudo umount edit/dev

sudo su << EOF
chmod +w extract-cd/casper/filesystem.manifest
chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
exit
EOF

sudo cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop

sudo rm -f extract-cd/casper/filesystem.squashfs
sudo mksquashfs edit extract-cd/casper/filesystem.squashfs -comp xz

sudo su << EOF
printf $(du -sx --block-size=1 edit | cut -f1) > extract-cd/casper/filesystem.size
exit
EOF

# sudo nano extract-cd/README.diskdefines

cd extract-cd
sudo rm MD5SUMS
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee MD5SUMS

sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../custom-$ISO .

cd ..
sudo chmod 777 custom-$ISO
isohybrid custom-$ISO

cd ..
sudo umount livecdtmp/mnt
sudo chmod -R 777 livecdtmp
rm -rf livecdtmp/edit livecdtmp/extract-cd livecdtmp/mnt
