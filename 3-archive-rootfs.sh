#!/bin/bash

TAR_EXTENSION=.tar.gz

# Check architecture and set variables
if [[ ! $check_and_set ]]; then
    . 0-check-and-set.sh $1
fi

rootfs_dir_utc=`readlink $build_dir/$rootfs_dir`
tar_name=$rootfs_dir_utc$TAR_EXTENSION

cd $build_dir
tar cfz $tar_name $rootfs_dir_utc
cd - >/dev/null

echo
echo "$build_dir/$tar_name created"
