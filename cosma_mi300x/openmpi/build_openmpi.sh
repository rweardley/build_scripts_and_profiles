#!/bin/bash

# set openmpi install location

OPENMPI_VERSION="openmpi-5.0.5"
MY_HOME=${HOME}
INSTALL_DIR=$MY_HOME/openmpi_custom
OMPI_DIR=$INSTALL_DIR/openmpi-install
#HELP2MAN_DIR=$INSTALL_DIR/help2man
#LIBTOOL_DIR=$INSTALL_DIR/libtool
UCX_DIR=$INSTALL_DIR/ucx
UCC_DIR=$INSTALL_DIR/ucc
DOWNLOAD_DIR=$INSTALL_DIR/downloads
OMPI_PROFILE=$MY_HOME/.openmpi_profile

BUILD_JOBS=8

#export CC=hipcc # maybe export CC=gcc
#export CXX=hipcc # maybe export CC=g++

# make directories
mkdir -p $DOWNLOAD_DIR
mkdir -p $INSTALL_DIR

# build help2man
#cd $DOWNLOAD_DIR
#wget https://ftp.gnu.org/gnu/help2man/help2man-1.49.3.tar.xz
#tar -xvf help2man-1.49.3.tar.xz
#rm help2man-1.49.3.tar.xz
#cd help2man-1.49.3
#./configure --prefix=$HELP2MAN_DIR
#make -j $BUILD_JOBS install
#export HELP2MAN=$HELP2MAN_DIR/bin/

# build libtool
# for help see https://savannah.gnu.org/projects/libtool/
#cd $DOWNLOAD_DIR
#wget https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.xz
#tar -xvf libtool-2.4.7.tar.xz
#rm libtool-2.4.7.tar.xz
#cd libtool-2.4.7
#./configure --prefix=$LIBTOOL_DIR
#make -j $BUILD_JOBS install

# generate derived files (configure scripts, C++ and F77 bindings)

#export PATH=$LIBTOOL_DIR/bin:$PATH
#export ACLOCAL_PATH=$LIBTOOL_DIR/share/aclocal:$ACLOCAL_PATH

# build UCX
cd $DOWNLOAD_DIR
git clone https://github.com/openucx/ucx.git
cd ucx
./autogen.sh
./contrib/configure-release --prefix=$UCX_DIR --with-rocm
make -j $BUILD_JOBS install

# build UCC
cd $DOWNLOAD_DIR
git clone https://github.com/openucx/ucc.git
cd ucc
./autogen.sh
./configure --prefix=$UCC_DIR --with-ucx=$UCX_DIR --with-rocm
make -j $BUILD_JOBS install

# build OpenMPI
cd $DOWNLOAD_DIR
wget https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.5.tar.gz
gunzip -c $OPENMPI_VERSION.tar.gz | tar xf -
cd $OPENMPI_VERSION
./configure --prefix=$OMPI_DIR --with-ucx=$UCX_DIR --with-ucc=$UCC_DIR --with-rocm
make -j $BUILD_JOBS install

# write OpenMPI profile

#echo "export PATH=$LIBTOOL_DIR/bin:$PATH" > $MPICH_PROFILE
#echo "export ACLOCAL_PATH=$LIBTOOL_DIR/share/aclocal:$ACLOCAL_PATH" >> $MPICH_PROFILE
echo "export CPATH=$OMPI_DIR/include:\$CPATH" > $OMPI_PROFILE
echo "export LIBRARY_PATH=$OMPI_DIR/lib:\$LIBRARY_PATH" >> $OMPI_PROFILE
echo "export PKG_CONFIG_PATH=$OMPI_DIR/lib/pkgconfig:\$PKG_CONFIG_PATH" >> $OMPI_PROFILE
echo "export LD_LIBRARY_PATH=$OMPI_DIR/lib:\$LD_LIBRARY_PATH" >> $OMPI_PROFILE
echo "export PATH=$OMPI_DIR/bin:\$PATH" >> $OMPI_PROFILE
echo "export CMAKE_PREFIX_PATH=$UCX_DIR:\$CMAKE_PREFIX_PATH" >> $OMPI_PROFILE
