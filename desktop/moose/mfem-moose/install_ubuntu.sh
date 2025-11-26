#!/bin/bash

# This script installs MFEM-MOOSE on Ubuntu,
# including a MOOSE framework build in the $HOME directory.
# Optimised to the native system architecture.
# A .mfem-moose_profile script is added to the $HOME directory.
# Use the installation by typing:
#   source $HOME/.mfem-moose_profile

export INSTALL_DIR=$HOME"/Programs"
export MFEM_MOOSE_DIR=$INSTALL_DIR"/mfem-moose"

# If MOOSE_JOBS is unset, set to 1
if [ -z $MOOSE_JOBS ]; then
    export MOOSE_JOBS=1
fi
export METHOD="opt"

#  set CUDA arch and path to CUDA
CUDA_DIR="/usr/local/cuda"
CUDA_ARCH_NUMBER="89"
CUDA_ARCH="sm_"$CUDA_ARCH_NUMBER

# Make MFEM-MOOSE profile
PROFILE_NAME="mfem-moose_profile"

echo "export CC=mpicc" > $HOME/.$PROFILE_NAME
echo "export CXX=mpicxx" >> $HOME/.$PROFILE_NAME
echo "export F90=mpif90" >> $HOME/.$PROFILE_NAME
echo "export F77=mpif77" >> $HOME/.$PROFILE_NAME
echo "export FC=mpif90" >> $HOME/.$PROFILE_NAME
echo "export MOOSE_DIR="$MFEM_MOOSE_DIR"" >> $HOME/.$PROFILE_NAME
echo "export PATH=\$PATH:"$MFEM_MOOSE_DIR >> $HOME/.$PROFILE_NAME
echo "export PATH=\$PATH:$CUDA_DIR/bin" >> $HOME/.$PROFILE_NAME
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$CUDA_DIR/lib64" >> $HOME/.$PROFILE_NAME
source $HOME/.$PROFILE_NAME

# Clone MOOSE from git

cd $INSTALL_DIR
git clone https://github.com/idaholab/moose.git mfem-moose
cd $MFEM_MOOSE_DIR
git checkout next

# Build PETSc

unset PETSC_DIR PETSC_ARCH
./scripts/update_and_rebuild_petsc.sh \
    --CXXOPTFLAGS="-O3 -march=native" \
    --COPTFLAGS="-O3 -march=native" \
    --FOPTFLAGS="-O3 -march=native" \
    --with-cuda
    --with-cuda-arch=$CUDA_ARCH

# Build libMesh

./scripts/update_and_rebuild_libmesh.sh \
    --with-mpi \
    2>&1 | tee $MFEM_MOOSE_DIR/log.libmesh_build

# Build Conduit

./scripts/update_and_rebuild_conduit.sh \
    --with-mpi \
    2>&1 | tee $MFEM_MOOSE_DIR/log.conduit_build

# Build WASP

./scripts/update_and_rebuild_wasp.sh \
    2>&1 | tee $MFEM_MOOSE_DIR/log.wasp_build

# Build MFEM

./scripts/update_and_rebuild_mfem.sh \
    -DMFEM_USE_CUDA=YES \
    -DCUDA_ARCH=$CUDA_ARCH \
    2>&1 | tee $MFEM_MOOSE_DIR/log.mfem_build


# Configure MOOSE with MFEM

./configure --with-mfem 2>&1 | tee $MFEM_MOOSE_DIR/log.mfem-moose_configure

cd framework
make -j $MOOSE_JOBS 2>&1 | tee $MFEM_MOOSE_DIR/log.framework_build
cd ../modules
make -j $MOOSE_JOBS 2>&1 | tee $MFEM_MOOSE_DIR/log.modules_build
cd ../test
make -j $MOOSE_JOBS 2>&1 | tee $MFEM_MOOSE_DIR/log.test_build

echo "Installation complete."
