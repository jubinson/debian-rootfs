# debian-rootfs
Generation of Debian rootfs for multiple architectures

This project relies on multistrap and thus can only be used on Debian/Ubuntu host system.  
Its purpose is to automate the generation of Debian rootfs for the following architectures:  
 - [amd64](https://www.dropbox.com/s/lx1xwi69gxasbeq/amd64-rootfs-20170318T102216Z.tar.gz?dl=1)
 - [arm64](https://www.dropbox.com/s/zxfg8aosr7zzmg8/arm64-rootfs-20170318T102424Z.tar.gz?dl=1)
 - [armel](https://www.dropbox.com/s/o1oejovcuogkm97/armel-rootfs-20170318T102727Z.tar.gz?dl=1)
 - [armhf](https://www.dropbox.com/s/6uqm7kxg327aex7/armhf-rootfs-20170310T075755Z.tar.gz?dl=1)
 - [i386](https://www.dropbox.com/s/5391fa4rupha36x/i386-rootfs-20170318T102946Z.tar.gz?dl=1)
 - [mips](https://www.dropbox.com/s/m80krqbeb09g2ht/mips-rootfs-20170318T103202Z.tar.gz?dl=1)
 - [mipsel](https://www.dropbox.com/s/s3o6uv4cv79vn6k/mipsel-rootfs-20170318T103423Z.tar.gz?dl=1)
 - [powerpc](https://www.dropbox.com/s/bh5jrdjpghb3vnm/powerpc-rootfs-20170315T172002Z.tar.gz?dl=1)
 - [powerpcspe](https://www.dropbox.com/s/leb1m6y1se3sqcr/powerpcspe-rootfs-20170310T152932Z.tar.gz?dl=1)
 - [ppc64el](https://www.dropbox.com/s/h9m2orpxcq6tkz1/ppc64el-rootfs-20170318T103722Z.tar.gz?dl=1)
 - [s390x](https://www.dropbox.com/s/9p0zmj47ellvxxe/s390x-rootfs-20170318T104029Z.tar.gz?dl=1)

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
