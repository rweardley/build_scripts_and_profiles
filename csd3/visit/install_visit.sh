#!/bin/bash

VERSION_MAJOR=3
VERSION_MINOR=5
VERSION_PATCH=0

INSTALL_DIR=$MY_RDS/visit

PLATFORM=linux-x86_64-rockylinux9

VERSION_PERIOD=${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}
VERSION_USCORE=${VERSION_MAJOR}_${VERSION_MINOR}_${VERSION_PATCH}

VISIT_RELEASE=https://github.com/visit-dav/visit/releases/download/v${VERSION_PERIOD}

mkdir temp
cd temp
wget ${VISIT_RELEASE}/visit-install${VERSION_USCORE}
wget ${VISIT_RELEASE}/visit${VERSION_USCORE}.${PLATFORM}.tar.gz

chmod +x visit-install${VERSION_USCORE}

./visit-install${VERSION_USCORE} $VERSION_PERIOD $PLATFORM $INSTALL_DIR << EOF 2>&1 | tee ../log.install
1
EOF

cd ..
rm -r temp