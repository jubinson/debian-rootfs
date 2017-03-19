#!/bin/bash

build_packages=( multistrap binfmt-support qemu-user-static )
sshd_packages=( ssh openssh-server )
conf_default=multistrap.conf
conf_powerpcspe=multistrap_debian-ports.conf
conf_s390x=multistrap_no-sshd.conf
rootfs_suffix=rootfs

unset check_and_set

# Available architectures with their associated qemu
declare -A qemu_static
#qemu_static[amd64]=qemu-x86_64-static => see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=703825
qemu_static[arm64]=qemu-aarch64-static
qemu_static[armel]=qemu-arm-static
qemu_static[armhf]=qemu-arm-static
qemu_static[i386]=qemu-i386-static
qemu_static[mips]=qemu-mips-static
qemu_static[mipsel]=qemu-mipsel-static
qemu_static[powerpc]=qemu-ppc-static
qemu_static[powerpcspe]=qemu-ppc-static
qemu_static[ppc64el]=qemu-ppc64le-static
qemu_static[s390x]=qemu-s390x-static

print_archs() {
    echo "    - $host_arch"
    for i in ${!qemu_static[@]}; do
	if [[ $i != $host_arch ]]; then
            echo "    - $i"
        fi
    done
}

# Ckeck script is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "`basename $0` needs to be sourced"
    exit 1
fi

# Get caller script
caller_script=`basename $(caller | awk '{print $2}')`
exit_or_return=`[[ $caller_script != NULL ]] && echo exit|| echo return`

# Make sure only root can run our script
if [[ $(id -u) != 0 ]]; then
   echo "This script must be run as root"
   $exit_or_return 1
fi

# Required packages to build rootfs
for i in ${build_packages[@]}; do
    if ! dpkg -s $i 2>/dev/null | grep -q "Status: install ok installed"; then
        echo "$i package is required, please install it"
        $exit_or_return 1
    fi
done

# Get host architecture
host_arch=`dpkg --print-architecture`

# Print usage
if [[ ! $1 || $1 == "-h" || $1 == "--help" ]]; then
    running_script=`[[ $caller_script != NULL ]] && echo $caller_script ||\
    echo "source \`basename ${BASH_SOURCE[0]}\`"`

    echo "usage: $running_script ARCHITECTURE [MULTISTRAP_CONF]"
    echo "  ARCHITECTURE can be:"
    print_archs
    echo "  MULTISTRAP_CONF is a multistrap configuration file"
    echo "                  defaults to $conf_default"
    echo "                  defaults to $conf_s390x for s390x"
    echo "                  defaults to $conf_powerpcspe for powerpcspe"
    $exit_or_return 1
fi
arch=$1

# Default multistrap configuration file
case $arch in
    powerpcspe) conf_file=$conf_powerpcspe ;;
    s390x) conf_file=$conf_s390x ;;
    *) conf_file=$conf_default
esac

# User defined multistrap configuration file
if [[ $2 ]]; then
    conf_file=$2
    if [[ ! -f $conf_file ]]; then
        echo "$conf_file file does not exist"
        $exit_or_return 1
    fi
fi

# Check architecture is suppported
if [[ $arch != $host_arch ]]; then
    if [[ ! ${qemu_static[$arch]} ]]; then
        echo "$arch not valid, architectures supported are:"
        print_archs
        $exit_or_return 1
    fi
    
    # Find qemu binary
    qemu_path=`which ${qemu_static[$arch]}`

    case $arch in
        powerpcspe)
            # Set qemu-ppc-static to support powerpcspe
            export QEMU_CPU=e500v2
            ;;
        s390x)
            # qemu-s390x-static cannot install openssh-server
            for i in ${sshd_packages[@]}; do
	        if grep -q "\b$i\b" $conf_file; then
                    echo "$i package in $conf_file cannot be installed for s390x"
                    $exit_or_return 1
                fi
            done
            ;;
    esac
fi

# Create build directory
build_dir=build/$arch
mkdir -p $build_dir 2>/dev/null

# Set rootfs directory
rootfs_dir=$arch\-$rootfs_suffix

check_and_set=1
