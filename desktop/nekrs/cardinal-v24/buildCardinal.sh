#!/bin/bash

# This script builds downloads and builds Cardinal.
# To run the installation, run `./buildCardinal.sh`.
# Cardinal and its dependencies will be installed in a `cardinal_MHD` directory in $PWD.

### User settings ###

CARDINAL_PROFILE="cardinal_v24_profile"

# Set GPU backend(s)
CUDA=true
HIP=false
OPENCL=false

# Select dependencies - Cardinal installs NekRS and OpenMC by default
export ENABLE_NEK=true
export ENABLE_OPENMC=false
export ENABLE_DAGMC=false

# Set number of cores for compilation
export MOOSE_JOBS=12
export LIBMESH_JOBS=12

# Set installation directory
# Cardinal will be installed in a `cardinal_v24` directory inside this directory
INSTALL_DIR=$HOME/NekRS

### Don't modify anything below this ###

# write .cardinal_MHD_profile

echo 'PS1="\e[1;31m(Cardinal)\e[0m "$PS1' > $HOME/.$CARDINAL_PROFILE
echo "export CC=mpicc" >> $HOME/.$CARDINAL_PROFILE
echo "export CXX=mpicxx" >> $HOME/.$CARDINAL_PROFILE
echo "export FC=mpif90" >> $HOME/.$CARDINAL_PROFILE
echo "export PATH=\$PATH:/usr/local/cuda-12/bin" >> $HOME/.$CARDINAL_PROFILE	# desktop only
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/cuda-12/lib64" >> $HOME/.$CARDINAL_PROFILE	# desktop only
echo "export CARDINAL_DIR=${INSTALL_DIR}/cardinal_MHD" >> $HOME/.$CARDINAL_PROFILE
echo "export PATH=\$PATH:\$CARDINAL_DIR" >> $HOME/.$CARDINAL_PROFILE
if $ENABLE_NEK ; then
    echo "export NEKRS_HOME=${INSTALL_DIR}/cardinal_MHD/install" >> $HOME/.$CARDINAL_PROFILE
fi

source $HOME/.$CARDINAL_PROFILE

# Get Cardinal & dependencies

cd $INSTALL_DIR
git clone https://github.com/neams-th-coe/cardinal.git cardinal_v24
cd cardinal_v24

./scripts/get-dependencies.sh
./contrib/moose/scripts/update_and_rebuild_petsc.sh
./contrib/moose/scripts/update_and_rebuild_libmesh.sh --with-mpi
./contrib/moose/scripts/update_and_rebuild_wasp.sh

# v24: replace the NekRS repo with the v24 version
cd contrib
rm -rf nekRS
git clone git@github.com:Nek5000/nekRS.git
cd nekRS
git checkout v24-development
cd $INSTALL_DIR/cardinal_v24

# Enable backends

if $CUDA ; then
    sed -i s/"OCCA_CUDA_ENABLED=0"/"OCCA_CUDA_ENABLED=1"/g Makefile
fi
if $HIP ; then
    sed -i s/"OCCA_HIP_ENABLED=0"/"OCCA_HIP_ENABLED=1"/g Makefile
fi
if $OPENCL ; then
    sed -i s/"OCCA_OPENCL_ENABLED=0"/"OCCA_OPENCL_ENABLED=1"/g Makefile
fi

make -j$MOOSE_JOBS MAKEFLAGS=-j$MOOSE_JOBS

echo "Installation complete."
