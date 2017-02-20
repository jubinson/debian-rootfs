#!/bin/bash

TAR_EXTENSION=.tar.gz

# Check architecture and set variables
if [[ ! $check_and_set ]]; then
    . 0-check-and-set.sh $1
fi

tar cfz $build_dir/$rootfs_dir$TAR_EXTENSION $build_dir/$rootfs_dir

echo
echo "$build_dir/$rootfs_dir$TAR_EXTENSION created"
