#!/bin/bash

# To-Do:
# Check requirements;
# The autoconf macros and the configure.in scripts now require the following:
# autoconf version 2.67 (or higher)
# automake version 1.12.3 (or higher)
# GNU libtool version 2.4 (or higher)
# Set up the environment that this builds in; presumably need all same requirements
# as NekRS, except intel-oneapi-mpi since this is taking the place of that module
# Not sure if this will work for the interconnect etc. without careful configuration.
# Run it on compute nodes; change make -jX

# Current issues
# Bizarrely, /usr/bin/libtool exists on login nodes, but not on Dawn nodes

# set mpich install location

INSTALLATION_PREFIX=$HOME/mpich-install

# set up environment

module purge
module load default-dawn
module load intel-oneapi-compilers

# get mpich

git clone https://github.com/pmodels/mpich.git
cd mpich

# get submodules

git submodule update --init

# generate derived files (configure scripts, C++ and F77 bindings)

find . -name configure -print | xargs rm
#./autogen.sh
AUTOCONF='/usr/bin/autoconf' libtooldir='/usr/bin' ./autogen.sh

# build mpich

./configure --prefix=$INSTALLATION_PREFIX
make -j24
make -j24 install

