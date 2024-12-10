#!/bin/bash

# Run it on compute nodes; change make -jX at the end for different resources
# Builds libtool and help2man dependencies as these don't exist on Dawn compute nodes

# set mpich install location

MY_HOME=${HOME}/rupert
INSTALL_DIR=$MY_HOME/mpich_custom
MPICH_DIR=$INSTALL_DIR/mpich-install
HELP2MAN_DIR=$INSTALL_DIR/help2man
LIBTOOL_DIR=$INSTALL_DIR/libtool
DOWNLOAD_DIR=$INSTALL_DIR/downloads
UCX_DIR=$INSTALL_DIR/ucx
UCC_DIR=$INSTALL_DIR/ucc
MPICH_PROFILE=$MY_HOME/.mpich_profile

CROSS_FILE=$INSTALL_DIR/cross_manual

BUILD_JOBS=32

export CC=hipcc
export CXX=hipcc
export FC=gfortran
export F77=gfortran
export F90=gfortran

# make directories
mkdir -p $DOWNLOAD_DIR

# build help2man
cd $DOWNLOAD_DIR
wget https://ftp.gnu.org/gnu/help2man/help2man-1.49.3.tar.xz
tar -xvf help2man-1.49.3.tar.xz
rm help2man-1.49.3.tar.xz
cd help2man-1.49.3
./configure --prefix=$HELP2MAN_DIR
make -j $BUILD_JOBS install
export HELP2MAN=$HELP2MAN_DIR/bin/

# build libtool
# for help see https://savannah.gnu.org/projects/libtool/
cd $DOWNLOAD_DIR
wget https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.xz
tar -xvf libtool-2.4.7.tar.xz
rm libtool-2.4.7.tar.xz
cd libtool-2.4.7
./configure --prefix=$LIBTOOL_DIR
make -j $BUILD_JOBS install

export PATH=$LIBTOOL_DIR/bin:$PATH
export ACLOCAL_PATH=$LIBTOOL_DIR/share/aclocal:$ACLOCAL_PATH

# build UCX
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

# get mpich

cd $DOWNLOAD_DIR
git clone https://github.com/pmodels/mpich.git
cd mpich

# get submodules

git submodule update --init

# generate derived files (configure scripts, C++ and F77 bindings)

./autogen.sh

# mpich struggles to detect Fortran datatpe sizes; this helps
echo "CROSS_F77_SIZEOF_INTEGER=4" > $CROSS_FILE
echo "CROSS_F77_SIZEOF_REAL=4" >> $CROSS_FILE
echo "CROSS_F77_SIZEOF_DOUBLE_PRECISION=8" >> $CROSS_FILE
echo "CROSS_F90_ADDRESS_KIND=8" >> $CROSS_FILE
echo "CROSS_F90_OFFSET_KIND=8" >> $CROSS_FILE
echo "CROSS_F90_INTEGER_KIND=8" >> $CROSS_FILE
echo "CROSS_F90_REAL_MODEL=6,37" >> $CROSS_FILE
echo "CROSS_F90_DOUBLE_MODEL=15,307" >> $CROSS_FILE
echo "CROSS_F90_INTEGER_MODEL_MAP={9,4,4}," >> $CROSS_FILE
echo "CROSS_F77_TRUE_VALUE=1" >> $CROSS_FILE
echo "CROSS_F77_FALSE_VALUE=0" >> $CROSS_FILE

# build mpich

./configure --prefix=$MPICH_DIR --with-hip-include=/opt/rocm/include --with-hip-lib=/opt/rocm/lib --with-cross=$CROSS_FILE --with-ucx=$UCX_DIR --with-ucc=$UCC_DIR
make -j $BUILD_JOBS install

# write MPICH profile

echo "export PATH=$LIBTOOL_DIR/bin:\$PATH" > $MPICH_PROFILE
echo "export ACLOCAL_PATH=$LIBTOOL_DIR/share/aclocal:\$ACLOCAL_PATH" >> $MPICH_PROFILE
echo "export CPATH=$MPICH_DIR/include:\$CPATH" >> $MPICH_PROFILE
echo "export LIBRARY_PATH=$MPICH_DIR/lib:\$LIBRARY_PATH" >> $MPICH_PROFILE
echo "export PKG_CONFIG_PATH=$MPICH_DIR/lib/pkgconfig:$\PKG_CONFIG_PATH" >> $MPICH_PROFILE
echo "export LD_LIBRARY_PATH=$MPICH_DIR/lib:$\LD_LIBRARY_PATH" >> $MPICH_PROFILE
echo "export PATH=$MPICH_DIR/bin:\$PATH" >> $MPICH_PROFILE
echo "export PATH=$UCX_DIR/bin:\$PATH" >> $MPICH_PROFILE
echo "export CPATH=$UCX_DIR/include:\$CPATH" >> $MPICH_PROFILE
echo "export CMAKE_PREFIX_PATH=$UCX_DIR:\$CMAKE_PREFIX_PATH" >> $MPICH_PROFILE
echo "export LD_LIBRARY_PATH=$UCX_DIR/lib:\$LD_LIBRARY_PATH" >> $MPICH_PROFILE
echo "export LIBRARY_PATH=$UCX_DIR/lib:\$LIBRARY_PATH" >> $MPICH_PROFILE
echo "export PKG_CONFIG_PATH=$UCX_DIR/lib/pkgconfig:\$PKG_CONFIG_PATH" >> $MPICH_PROFILE
