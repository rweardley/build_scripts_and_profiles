#!/bin/bash

# CMake install settings

INSTALL_DIR=${HOME}/cmake
CMAKE_VERSION="3.31.6"

# Download and untar CMake binaries

mkdir $INSTALL_DIR
cd $INSTALL_DIR
wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz
tar -xvf cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz
