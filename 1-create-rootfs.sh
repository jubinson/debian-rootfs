#!/bin/bash

# Check architecture and set variables
if [[ ! $check_and_set ]]; then
    . 0-check-and-set.sh $1 $2
fi

# Set locale
LC_ALL=C LANGUAGE=C LANG=C

# Cleanup when interrupt signal is received
trap "umount $build_dir/$rootfs_dir/dev; exit 1" SIGINT

if [[ $arch == $host_arch ]]; then
    # Create /dev and /proc in rootfs
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

    # Empty root password
    chroot $build_dir/$rootfs_dir passwd -d root

    # Umount /dev in rootfs
    umount $build_dir/$rootfs_dir/dev
else
    # Create root file system
    multistrap -d $build_dir/$rootfs_dir -a $arch -f $conf_file
    if [[ $? != 0 ]]; then
        echo "mutltistrap with configuration file $conf_file failed"
	rm -rf $build_dir/$rootfs_dir
        exit 1
    fi

    # Copy qemu binary to rootfs
    cp $qemu_path $build_dir/$rootfs_dir$qemu_path

    # Mount /dev in rootfs
    mount --bind /dev $build_dir/$rootfs_dir/dev

    # Configure debian packages
    chroot $build_dir/$rootfs_dir dpkg --configure -a 

    # Empty root password
    chroot $build_dir/$rootfs_dir passwd -d root
    
    # Remove qemu binary from rootfs
    rm $build_dir/$rootfs_dir$qemu_path

    # Umount /dev in rootfs
    umount $build_dir/$rootfs_dir/dev
fi
