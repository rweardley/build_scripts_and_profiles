#!/bin/bash

# This script builds downloads and builds Cardinal.
# To run the installation, run `./buildCardinal.sh`.
# Cardinal and its dependencies will be installed in a `cardinal` directory in $PWD.

### User settings ###

# Set GPU backend(s)
CUDA=true
HIP=false
OPENCL=false

# Select dependencies - Cardinal installs NekRS and OpenMC by default
export ENABLE_NEK=true
export ENABLE_OPENMC=false
export ENABLE_DAGMC=false

# Set number of cores for compilation
export MOOSE_JOBS=32

# Set installation directory
# Cardinal will be installed in a `cardinal` directory inside this directory
INSTALL_DIR="${PWD}"

### Don't modify anything below this ###

# write .cardinal_profile

echo 'PS1="\e[1;31m(Cardinal)\e[0m "$PS1' > $HOME/.cardinal_profile
echo "module purge" >> $HOME/.cardinal_profile
echo "module load rhel8/default-amp" >> $HOME/.cardinal_profile
echo "module load python-3.9.6-gcc-5.4.0-sbr552h" >> $HOME/.cardinal_profile
echo "module load py-pyyaml-3.11-intel-17.0.4-kqsxqja" >> $HOME/.cardinal_profile
echo "module load py-packaging-16.8-gcc-5.4.0-x5zxajh" >> $HOME/.cardinal_profile
echo "export CC=mpicc" >> $HOME/.cardinal_profile
echo "export CXX=mpicxx" >> $HOME/.cardinal_profile
echo "export FC=mpif90" >> $HOME/.cardinal_profile
echo "export CARDINAL_DIR=${INSTALL_DIR}/cardinal" >> $HOME/.cardinal_profile
echo "export PATH=\$PATH:\$CARDINAL_DIR" >> $HOME/.cardinal_profile
if $ENABLE_NEK ; then
    echo "export NEKRS_HOME=${INSTALL_DIR}/cardinal/install" >> $HOME/.cardinal_profile
fi

source $HOME/.cardinal_profile

# Get Cardinal & dependencies

cd $INSTALL_DIR
git clone https://github.com/neams-th-coe/cardinal.git
cd cardinal

./scripts/get-dependencies.sh
./contrib/moose/scripts/update_and_rebuild_petsc.sh --download-cmake
# Use the PETSc-downloaded CMake for remainder of build
export PATH="$PWD/contrib/moose/petsc/arch-moose/bin:$PATH"
# optional sanity check
echo "Checking which cmake executable is being used..."
which cmake
echo "Displaying CMake version..."
cmake --version
./contrib/moose/scripts/update_and_rebuild_libmesh.sh --with-mpi
./contrib/moose/scripts/update_and_rebuild_wasp.sh

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
