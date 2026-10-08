# Magisk module with gcc 16.x toolchain

This repository contains the source files for a [Magisk](https://github.com/topjohnwu/Magisk) Module with **gcc 16.x toolchain** and the sysroot from the **Android NDK r30** compiled for **arm64** CPUs

Also included are the binaries **make**, **pkg-config**, and **pkgconf**.

The gcc toolchain was copied from this GitHub repository:

[https://github.com/AmanoTeam/android-gcc-cross](https://github.com/AmanoTeam/android-gcc-cross)

**Note**

That GitHub repository also contains gcc binaries for other CPUs. This GitHub repository only contains the files for **arm64** CPUs.


The version of the **gcc** and **g++** in the Magisk Module is:
```
ASUS_I006D:/data/local/tmp # gcc --version
aarch64-unknown-linux-android-gcc (GCC) 16.2.1 20261006
Copyright (C) 2026 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

ASUS_I006D:/data/local/tmp #

ASUS_I006D:/system/bin # g++ --version
aarch64-unknown-linux-android-g++ (GCC) 16.2.1 20261006
Copyright (C) 2026 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

ASUS_I006D:/system/bin #
```

The version of the additional tools in this repository are:
```
ASUS_I006D:/ $ make --version
GNU Make 4.1.90
Built for aarch64-unknown-linux-gnu
Copyright (C) 1988-2014 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
ASUS_I006D:/ $     

ASUS_I006D:/ $ pkg-config --version           
0.29
ASUS_I006D:/ $      

ASUS_I006D:/ $ pkgconf --version
2.3.0
ASUS_I006D:/ $
```

To create the Magisk Module, clone the repository
```
git clone https://github.com/bnsmb/Magisk-module-with-gcc-16.x.git
```
and execute the script **create_zip.sh**:
```
cd Magisk-module-with-gcc-16.x/
./create_zip.sh
```

See the file [README](https://github.com/bnsmb/Magisk-module-with-gcc-16.x/blob/main/README) in the repository for more infos.

The detailed documentation for the Magisk Module can be found here:

[http://bnsmb.de/Magisk_Modules.html#Documentation_for_the_Magisk_Module_with_gcc](http://bnsmb.de/Magisk_Modules.html#Documentation_for_the_Magisk_Module_with_gcc)

and in this post on XDA:

[https://xdaforums.com/t/module-a-magisk-module-with-a-gcc-16-x-toolchain.4804271/](https://xdaforums.com/t/module-a-magisk-module-with-a-gcc-16-x-toolchain.4804271/)

----

**Notes**

As of **08.10.2026** the repository with the gcc toolchain ([https://github.com/AmanoTeam/android-gcc-cross](https://github.com/AmanoTeam/android-gcc-cross)) only contains a [script](https://github.com/AmanoTeam/android-gcc-cross#termux) to install the gcc toolchain in a [Termux](https://termux.dev/en/) environment on a phone or tablet.

To install the gcc toolchain on a phone or tablet without **Termux** the script

[gcc_install.sh](https://github.com/bnsmb/Magisk-module-with-gcc-16.x/blob/main/source/install_gcc.sh)

from this repository can be used. **gcc_install.sh** downloads and uses the installation script from the gcc repository with a few modifications to install the gcc toolchain.

----

**Credits**

Many thanks to Amano LLC ([https://amanoteam.com/](https://amanoteam.com/)) for developing the gcc toolchain for Android ([https://github.com/AmanoTeam/android-gcc-cross](https://github.com/AmanoTeam/android-gcc-cross))


----
