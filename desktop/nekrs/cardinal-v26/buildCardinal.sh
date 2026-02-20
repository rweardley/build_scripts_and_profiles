#!/bin/bash

# This script builds downloads and builds Cardinal.
# To run the installation, run `./buildCardinal.sh`.
# Cardinal and its dependencies will be installed in a `cardinal-v26` directory in $PWD.

# To create the python environment required for this script,
# first run `setup_cardinal_build_env.sh`,
# then load the environment with `source cardinal-py-env/bin/activate`

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
export MOOSE_JOBS=8
export LIBMESH_JOBS=8

# Set installation directory

INSTALL_DIR=${HOME}/NekRS
DIR_NAME=cardinal-v26

# set path to CUDA
CUDA_DIR=$HOME/Programs/cuda/cuda-12.2

### Don't modify anything below this ###

# write .cardinal_v26_profile

PROFILE_NAME=cardinal_v26_profile

echo 'PS1="\e[1;31m(Cardinal)\e[0m "$PS1' > $HOME/.$PROFILE_NAME
echo "export CC=mpicc" >> $HOME/.$PROFILE_NAME
echo "export CXX=mpicxx" >> $HOME/.$PROFILE_NAME
echo "export FC=mpif90" >> $HOME/.$PROFILE_NAME

echo "export CUDA_DIR=$CUDA_DIR" >> $HOME/.$PROFILE_NAME
echo "export PATH=\${CUDA_DIR}/bin:\${PATH}" >> $HOME/.$PROFILE_NAME
echo "export CPATH=\${CUDA_DIR}/include:\${CPATH}" >> $HOME/.$PROFILE_NAME
echo "export LIBRARY_PATH=\${CUDA_DIR}/lib64:\${LIBRARY_PATH}" >> $HOME/.$PROFILE_NAME
echo "export LD_LIBRARY_PATH=\${CUDA_DIR}/lib64:\${LD_LIBRARY_PATH}" >> $HOME/.$PROFILE_NAME
echo "export CUDAToolkit_ROOT=\${CUDA_DIR}" >> $HOME/.$PROFILE_NAME
echo "export CMAKE_CUDA_TOOLKIT_ROOT_DIR=\${CUDA_DIR}" >> $HOME/.$PROFILE_NAME
echo "export NVCC=\${CUDA_DIR}/bin/nvcc" >> $HOME/.$PROFILE_NAME
echo "export CUDACXX=\${CUDA_DIR}/bin/nvcc" >> $HOME/.$PROFILE_NAME
echo "export CMAKE_CUDA_COMPILER=\${CUDA_DIR}/bin/nvcc" >> $HOME/.$PROFILE_NAME

echo "export CARDINAL_DIR=${INSTALL_DIR}/${DIR_NAME}" >> $HOME/.$PROFILE_NAME
echo "export PATH=\$PATH:\$CARDINAL_DIR" >> $HOME/.$PROFILE_NAME
if $ENABLE_NEK ; then
    echo "export NEKRS_HOME=${INSTALL_DIR}/${DIR_NAME}/install" >> $HOME/.$PROFILE_NAME
fi

source $HOME/.$PROFILE_NAME

# check we are using the expected CUDA toolkit
echo "CUDA nvcc:" "$(command -v nvcc)"
nvcc --version

# Get Cardinal & dependencies

cd $INSTALL_DIR
# git clone https://github.com/neams-th-coe/cardinal.git $DIR_NAME
git clone -b update-v25 https://github.com/nandu90/cardinal.git $DIR_NAME
cd $INSTALL_DIR/$DIR_NAME

./scripts/get-dependencies.sh
./contrib/moose/scripts/update_and_rebuild_petsc.sh --download-cmake
# Use the PETSc-downloaded CMake for remainder of build
export PATH="$PWD/contrib/moose/petsc/arch-moose/bin:$PATH"
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
