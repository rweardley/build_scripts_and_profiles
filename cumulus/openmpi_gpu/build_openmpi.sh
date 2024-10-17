#!/bin/bash

openmpi_download_dir=$HOME/Downloads
openmpi_install_dir=$HOME/OpenMPI

openmpi_major_version=4.1
openmpi_minor_version=6
openmpi_version=${openmpi_major_version}.${openmpi_minor_version}

# Load required modules
module load CUDA/11.7.0
#module load GCC/12.3.0
#module load hwloc/2.9.1-GCCcore-12.3.0
#module load libevent/2.1.12-GCCcore-12.3.0
#module load UCX/1.14.1-GCCcore-12.3.0
#module load libfabric/1.18.0-GCCcore-12.3.0
#module load PMIx/4.2.4-GCCcore-12.3.0
#module load UCC/1.2.0-GCCcore-12.3.0

# Get OpenMPI
# Can't use wget on the compute nodes so get it on the login nodes
# with e.g. `wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.6.tar.gz`
cd ${openmpi_download_dir}
tar -xf openmpi-${openmpi_version}.tar.gz
cd openmpi-${openmpi_version}

which gcc
gcc --version

# Configure OpenMPI
./configure --prefix=${openmpi_install_dir} --with-cuda --with-pmix=internal --with-hwloc=internal --with-libevent=internal

# Build OpenMPI
make all install
