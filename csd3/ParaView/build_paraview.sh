#!/bin/bash

PARAVIEW_VERSION=v5.13.3
PARAVIEW_DIR=${HOME}/ParaView/ParaView-v${PARAVIEW_VERSION}

module load ninja qt

mkdir -p ${PARAVIEW_DIR}
cd ${PARAVIEW_DIR}

#git clone https://gitlab.kitware.com/paraview/paraview.git
mkdir paraview_build
cd paraview
git checkout ${PARAVIEW_VERSION}
git submodule update --init --recursive
cd ../paraview_build
cmake -GNinja -DPARAVIEW_USE_PYTHON=ON -DPARAVIEW_USE_MPI=ON -DVTK_SMP_IMPLEMENTATION_TYPE=TBB -DCMAKE_BUILD_TYPE=Release ../paraview
ninja
