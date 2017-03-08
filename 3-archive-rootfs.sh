#!/bin/bash

TAR_EXTENSION=.tar.gz

# Check architecture and set variables
if [[ ! $check_and_set ]]; then
    . 0-check-and-set.sh $1
fi

cd $build_dir
tar cfz $rootfs_dir$TAR_EXTENSION $rootfs_dir
cd - >/dev/null

echo
echo "$build_dir/$rootfs_dir$TAR_EXTENSION created"
