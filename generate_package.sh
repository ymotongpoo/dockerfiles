#!/bin/bash
workdir=$1
built_go_dir=$2
debian_workroot=$3
install_target=$4
control_file=${debian_workroot}/DEBIAN/control
copyright_file=${debian_workroot}/DEBIAN/copyright
preinst_file=${debian_workroot}/DEBIAN/preinst

cd ${built_go_dir}
rev=`git rev-parse --short HEAD`

# create control file
cd ${debian_workroot}
touch ${control_file}
echo "Package: golang" >> ${control_file}
echo "Maintainer: Yoshi Yamaguchi <ymotongpoo@gmail.com>" >> ${control_file}
echo "Architecture: amd64" >> ${control_file}
echo "Version: ${rev}" >> ${control_file}
echo "Section: devel" >> ${control_file}
echo "Priority: extra" >> ${control_file}
echo "Homepage: https://golang.org/" >> ${control_file}
echo "Depends: libc6" >> ${control_file}
echo "Recommends: g++, gcc, pkg-config, libc6-dev" >> ${control_file}
echo "Suggests: git, mercurial, bzr, subversion" >> ${control_file}
echo "Description: latest version of pre-built go binary." >> ${control_file}
echo " Go is a programming language for general use." >> ${control_file}
echo " This pre-built binary is for testing use and may be unstable." >> ${control_file}
echo " Stable binary is distributed on the official website." >> ${control_file}
echo " Check https://golang.org/dl/ for them." >> ${control_file}

cd ${workdir}
cp -r $built_go_dir/. $install_target
fakeroot dpkg-deb --build $debian_workroot .
echo "done creating debian package: $(ls *.deb)"

# create copyright file
cd ${debian_workroot}

copyright_text=$(cat << EOS
This package was debianized by Yoshi Yamaguchi <ymotongpoo@gmail.com>.
Original authors are The Go Authors. See all authors in:
https://go.googlesource.com/go/+/master/AUTHORS

Copyright Holder: Yoshi Yamaguchi <ymotongpoo@gmail.com>

License:

BSD 3 Clause license.
/usr/share/common-licenses/BSD
EOS
)

echo $copyright_text >> ${copyright_file}

# create preinst file
cd ${debian_workroot}

cleanup_text=$(cat << PRE
if [ -d /opt/go ]; then
  rm -rf /opt/go
fi
PRE
)

echo ${cleanup_text} >> ${preinst_file}
