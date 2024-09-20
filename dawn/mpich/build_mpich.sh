#!/bin/bash

# Run it on compute nodes; change make -jX at the end for different resources
# Builds libtool and help2man dependencies as these don't exist on Dawn compute nodes

# set mpich install location

INSTALL_DIR=$HOME/mpich_custom
MPICH_DIR=$INSTALL_DIR/mpich-install
HELP2MAN_DIR=$INSTALL_DIR/help2man
LIBTOOL_DIR=$INSTALL_DIR/libtool
DOWNLOAD_DIR=$INSTALL_DIR/downloads

# set up environment

module purge
module load default-dawn
module load intel-oneapi-compilers

# make directories
mkdir -p $DOWNLOAD_DIR

# build help2man
cd $DOWNLOAD_DIR
wget https://ftp.gnu.org/gnu/help2man/help2man-1.49.3.tar.xz
tar -xvf help2man-1.49.3.tar.xz
rm help2man-1.49.3.tar.xz
cd help2man-1.49.3
./configure --prefix=$HELP2MAN_DIR
make
make install
export HELP2MAN=$HELP2MAN_DIR/bin/

# build libtool
# for help see https://savannah.gnu.org/projects/libtool/
cd $DOWNLOAD_DIR
wget https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.xz
tar -xvf libtool-2.4.7.tar.xz
rm libtool-2.4.7.tar.xz
cd libtool-2.4.7
./configure --prefix=$LIBTOOL_DIR
make
make install

# get mpich

cd $DOWNLOAD_DIR
git clone https://github.com/pmodels/mpich.git
cd mpich

# get submodules

git submodule update --init

# generate derived files (configure scripts, C++ and F77 bindings)

export PATH=$LIBTOOL_DIR/bin:$PATH
export ACLOCAL_PATH=$LIBTOOL_DIR/share/aclocal:$ACLOCAL_PATH

./autogen.sh

# build mpich

./configure --prefix=$MPICH_DIR
make -j24
make -j24 install
