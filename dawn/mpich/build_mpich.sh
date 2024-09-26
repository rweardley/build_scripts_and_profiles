#!/bin/bash

# Run it on compute nodes; change make -jX at the end for different resources
# Builds libtool and help2man dependencies as these don't exist on Dawn compute nodes

# set mpich install location

INSTALL_DIR=$HOME/mpich_custom
MPICH_DIR=$INSTALL_DIR/mpich-install
HELP2MAN_DIR=$INSTALL_DIR/help2man
LIBTOOL_DIR=$INSTALL_DIR/libtool
DOWNLOAD_DIR=$INSTALL_DIR/downloads
MPICH_MODULE_DIR=$HOME/privatemodules
MPICH_MODULE=$MPICH_MODULE_DIR/mpich_custom

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

# create custom modulefile

mkdir -p $MPICH_MODULE_DIR
echo "#%Module1.0" > $MPICH_MODULE
echo "module-whatis {Custom MPICH module for multi-node NekRS on Dawn}" >> $MPICH_MODULE
echo "proc ModulesHelp { } { puts stderr {Name   : Custom MPICH} }" >> $MPICH_MODULE
echo "prepend-path PATH {$LIBTOOL_DIR/bin}" >> $MPICH_MODULE
echo "prepend-path ACLOCAL_PATH {$LIBTOOL_DIR/share/aclocal}" >> $MPICH_MODULE
echo "prepend-path CPATH {$MPICH_DIR/include}" >> $MPICH_MODULE
echo "setenv I_MPI_ROOT {$MPICH_DIR}" >> $MPICH_MODULE
echo "prepend-path LIBRARY_PATH {$MPICH_DIR/lib}" >> $MPICH_MODULE
echo "prepend-path PKG_CONFIG_PATH {$MPICH_DIR/lib/pkgconfig}" >> $MPICH_MODULE
echo "prepend-path LD_LIBRARY_PATH {$MPICH_DIR/lib}" >> $MPICH_MODULE
echo "prepend-path PATH {$MPICH_DIR/bin}" >> $MPICH_MODULE
echo "setenv I_MPI_CC {icx}" >> $MPICH_MODULE
echo "setenv I_MPI_CXX {icpx}" >> $MPICH_MODULE
echo "setenv I_MPI_F77 {ifx}" >> $MPICH_MODULE
echo "setenv I_MPI_F90 {ifx}" >> $MPICH_MODULE
echo "setenv I_MPI_FC {ifx}" >> $MPICH_MODULE
echo "append-path MANPATH {}" >> $MPICH_MODULE # might not be needed
