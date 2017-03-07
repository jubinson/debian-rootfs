#!/bin/bash

# Check architecture and set variables
if [[ ! $check_and_set ]]; then
    . 0-check-and-set.sh $1 $2
fi

# Cleanup when interrupt signal is received
trap "umount $build_dir/$rootfs_dir/dev; exit 1" SIGINT

if [[ $arch == $host_arch ]]; then
    # Create /dev in rootfs
    mkdir -p $build_dir/$rootfs_dir/dev 2>/dev/null

    # Mount /dev in rootfs
    mount --bind /dev $build_dir/$rootfs_dir/dev

    # Create root file system and configure debian packages
    multistrap -d $build_dir/$rootfs_dir -a $arch -f $conf_file
    if [[ $? != 0 ]]; then
        echo "mutltistrap with configuration file $conf_file failed"
        umount $build_dir/$rootfs_dir/dev
	rm -rf $build_dir/$rootfs_dir
        exit 1
    fi
else
    # Create root file system
    multistrap -d $build_dir/$rootfs_dir -a $arch -f $conf_file
    if [[ $? != 0 ]]; then
        echo "mutltistrap with configuration file $conf_file failed"
	rm -rf $build_dir/$rootfs_dir
        exit 1
    fi

    # Set environment variables
    export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
    export LC_ALL=C LANGUAGE=C LANG=C

    # Copy qemu binary to rootfs
    cp $qemu_path $build_dir/$rootfs_dir$qemu_path

    # Mount /dev in rootfs
    mount --bind /dev $build_dir/$rootfs_dir/dev

    # Complete the configure of dash
    chroot $build_dir/$rootfs_dir /var/lib/dpkg/info/dash.preinst install

    # Configure debian packages
    chroot $build_dir/$rootfs_dir dpkg --configure -a 
fi

# Empty root password
chroot $build_dir/$rootfs_dir passwd -d root

# Remove qemu binary from rootfs
rm $build_dir/$rootfs_dir$qemu_path 2>/dev/null

# Umount /dev in rootfs
umount $build_dir/$rootfs_dir/dev
