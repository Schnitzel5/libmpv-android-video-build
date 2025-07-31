#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	make clean
	exit 0
else
	exit 255
fi

# Building seperately from source tree is not supported, this means we are forced to always clean
$0 clean

# -Dgetlocaledecpoint()=('.') fixes bionic missing decimal_point in localeconv
make CC="$CC" AR="$AR rc" RANLIB="$RANLIB" \
	MYCFLAGS="-fPIC -Dgetlocaledecpoint\(\)=\(\'.\'\)" \
	PLAT=linux -j$cores

# TO_BIN=/dev/null disables installing
make INSTALL=${INSTALL:-install} INSTALL_TOP="$prefix_dir" TO_BIN=/dev/null install

# make pc only generates a partial pkg-config file because ????
mkdir -p $prefix_dir/lib/pkgconfig
cat >$prefix_dir/lib/pkgconfig/mujs.pc <<"END"
Name: mujs
Description:
Version: ${version}
Libs: -L${libdir} -lmujs
Cflags: -I${includedir}
END
