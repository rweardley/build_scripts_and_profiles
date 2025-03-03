#!/bin/bash

# Requires VTK >= 9
# Ubuntu 22.04 and later: `sudo apt-get install libvtk9-dev`

# Set source address
# From https://doi.org/10.17632/d82hjm4v6r.1
SOURCE_ADDRESS=https://data.mendeley.com/public-files/datasets/d82hjm4v6r/files/7eae1e72-6e8e-485e-8ca7-872ef9d5352c/file_downloaded

# Set installation location

INSTALL_DIR=${HOME}/Programs
NEKMESH_DIR=NekMesh
TAR_NAME=NekMesh.tar.gz

# Set profile name
NEKMESH_PROFILE=".NekMesh_profile"

# Make directory
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# Get NekMesh
wget -O ${TAR_NAME} ${SOURCE_ADDRESS}
tar -xvf ${TAR_NAME}
rm ${TAR_NAME}
cd $INSTALL_DIR/$NEKMESH_DIR

# Compile NekMesh

cd nektar++
mkdir build && cd build
cmake -DNEKTAR_USE_MPI=ON .. -C ../cmake/NekMesh.cmake
make -j install

# Write NekMesh profile

echo export PATH='$PATH':$(pwd)/dist/bin >> $HOME/$NEKMESH_PROFILE
echo export PYTHONPATH=$(pwd) >> $HOME/$NEKMESH_PROFILE