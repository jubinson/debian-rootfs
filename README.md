# debian-rootfs
Generation of Debian rootfs for multiple architectures

This project relies on multistrap and thus can only be used on Debian/Ubuntu host system.  
Its purpose is to automate the generation of Debian rootfs for the following architectures:  
 - [amd64](http://pc.cd/HWhotalK)
 - [arm64](http://pc.cd/pWhotalK)
 - [armel](http://pc.cd/qshotalK)
 - [armhf](http://pc.cd/3shotalK)
 - [i386](http://pc.cd/LshotalK)
 - [mips](http://pc.cd/g2hotalK)
 - [mipsel](http://pc.cd/e2hotalK)
 - [powerpc](http://pc.cd/dDhotalK)
 - [powerpcspe](http://pc.cd/nshotalK)
 - [ppc64el](http://pc.cd/G2hotalK)
 - [s390x](http://pc.cd/UWhotalK)

The following packages need to be installed:  
`# apt-get install multistrap binfmt-support qemu-user-static`

To create a Debian rootfs, symply run:  
`# ./make-rootfs.sh ARCHITECTURE`

Default multistrap configuration files provide Debian packages suited to embedded targets.  
They have been tested on a Debian Jessie amd64 host system to build rootfs for all architectures.  
They can be modified/overriden if you want to add/remove packages installed by default.  

The generated rootfs are ready to use, no further configuration is required.  
The root user has an empty password and logs automativally in.  
A ssh server is also running (except for s390x), root can connect to it with an emtpy password.  

Once running on your target, the rootfs can be upgraded with apt-get commands.  

As examples, already built rootfs can be downloaded by clicking on the architecture name in the above list.  
