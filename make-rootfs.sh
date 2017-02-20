#!/bin/bash

. 0-check-and-set.sh $1 $2
. 1-create-rootfs.sh
. 2-configure-rootfs.sh
. 3-archive-rootfs.sh
