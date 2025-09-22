#!/bin/bash

# This script builds downloads and builds Cardinal.
# To run the installation, run `./buildCardinal.sh`.

### User settings ###

# Set GPU backend(s)
CUDA=false
HIP=false
OPENCL=false

# Select dependencies - Cardinal installs NekRS and OpenMC by default
export ENABLE_NEK=true
export ENABLE_OPENMC=false
export ENABLE_DAGMC=false

# Set number of cores for compilation
export MOOSE_JOBS=12

# Set installation directory
# Cardinal will be installed in a `cardinal` directory inside this directory
NEKRS_GENERAL_DIR=${HOME}/NekRS
INSTALL_DIR=${NEKRS_GENERAL_DIR}/cardinal

PROFILE_NAME=cardinal_profile

### Don't modify anything below this ###

mkdir -p $INSTALL_DIR

# Get Cardinal

cd $INSTALL_DIR
git clone https://github.com/neams-th-coe/cardinal.git
cd cardinal

# Create pip venv

python3 -m venv cardinal-py-env

# write .cardinal_profile

echo "export CC=mpicc" > $HOME/.$PROFILE_NAME
echo "export CXX=mpicxx" >> $HOME/.$PROFILE_NAME
echo "export FC=mpif90" >> $HOME/.$PROFILE_NAME
echo "export CARDINAL_DIR=${INSTALL_DIR}" >> $HOME/.$PROFILE_NAME
echo "export PATH=\$PATH:\$CARDINAL_DIR" >> $HOME/.$PROFILE_NAME
if $ENABLE_NEK ; then
    echo "export NEKRS_HOME=${INSTALL_DIR}/install" >> $HOME/.$PROFILE_NAME
fi
echo "source \$CARDINAL_DIR/cardinal-py-env/bin/activate" >> $HOME/.$PROFILE_NAME

source $HOME/.$PROFILE_NAME

# Get dependencies

cardinal-py-env/bin/pip3 install setuptools
cardinal-py-env/bin/pip3 install jinja2
cardinal-py-env/bin/pip3 install packaging
cardinal-py-env/bin/pip3 install pyyaml

./scripts/get-dependencies.sh
./contrib/moose/scripts/update_and_rebuild_petsc.sh
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
