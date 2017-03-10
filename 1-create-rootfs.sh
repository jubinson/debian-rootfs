#!/bin/bash

# Check architecture and set variables
if [[ ! $check_and_set ]]; then
    . 0-check-and-set.sh $1 $2
fi

# Get current UTC time
utc_time=`date -u -d"$(wget -qO- --save-headers http://www.debian.org |\
            sed '/^Date: /!d;s///;q')" +%Y%m%dT%H%M%SZ`
rootfs_dir_utc=$rootfs_dir-$utc_time

# Cleanup when interrupt signal is received
trap "umount $build_dir/$rootfs_dir_utc/dev; exit 1" SIGINT

if [[ $arch == $host_arch ]]; then
    # Create /dev in rootfs
    mkdir -p $build_dir/$rootfs_dir_utc/dev 2>/dev/null

    # Mount /dev in rootfs
    mount --bind /dev $build_dir/$rootfs_dir_utc/dev

    # Create root file system and configure debian packages
    multistrap -d $build_dir/$rootfs_dir_utc -a $arch -f $conf_file
    if [[ $? != 0 ]]; then
        echo "mutltistrap with configuration file $conf_file failed"
        umount $build_dir/$rootfs_dir_utc/dev
        rm -rf $build_dir/$rootfs_dir_utc
        exit 1
    fi
else
    # Create root file system
    multistrap -d $build_dir/$rootfs_dir_utc -a $arch -f $conf_file
    if [[ $? != 0 ]]; then
        echo "mutltistrap with configuration file $conf_file failed"
        rm -rf $build_dir/$rootfs_dir_utc
        exit 1
    fi

    # Set environment variables
    export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
    export LC_ALL=C LANGUAGE=C LANG=C

    # Copy qemu binary to rootfs
    cp $qemu_path $build_dir/$rootfs_dir_utc$qemu_path

    # Mount /dev in rootfs
    mount --bind /dev $build_dir/$rootfs_dir_utc/dev

    # Complete the configure of dash
    chroot $build_dir/$rootfs_dir_utc /var/lib/dpkg/info/dash.preinst install

    # Configure debian packages
    chroot $build_dir/$rootfs_dir_utc dpkg --configure -a
fi

# Empty root password
chroot $build_dir/$rootfs_dir_utc passwd -d root

# Get packages installed
chroot $build_dir/$rootfs_dir_utc dpkg -l | awk '{if (NR>3) {print $2" "$3}}' > $build_dir/$rootfs_dir_utc\-packages

# Kill processes running in rootfs
fuser -sk $build_dir/$rootfs_dir_utc

# Remove qemu binary from rootfs
rm $build_dir/$rootfs_dir_utc$qemu_path 2>/dev/null

# Umount /dev in rootfs
umount $build_dir/$rootfs_dir_utc/dev

# Latest rootfs is the current one
ln -sfn $rootfs_dir_utc $build_dir/$rootfs_dir
