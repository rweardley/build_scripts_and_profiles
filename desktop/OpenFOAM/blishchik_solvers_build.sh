#!/bin/bash

# Blishchik mhdEpot solver compilation process

pwd	# should be the git repo clone, i.e. MHD_Solvers_OpenFOAM if not renamed

cd solvers

#

cd mhdEpotBuoyantBoussinesqPimpleFoam
wmake
cd ..

#

cd mhdEpotFoam
wmake
cd ..

#

cd mhdEpotInterFoam
cd transportModels
cd incompressible
wmake
cd ../immiscibleIncompressibleTwoPhaseMhdMixture
wmake
cd ../..
wmake
cd ..

#

cd mhdEpotMultiRegionFoam
wmake
cd ..

#

cd mhdEpotMultiRegionInterFoam
cd transportModels
cd incompressible
wmake
cd ../immiscibleIncompressibleTwoPhaseMhdMixture
wmake
cd ../..
wmake
cd ..

#

cd ../turbulenceModels

# 

cd dynamicSmagorinsky
wmake
cd ..

#

cd kEpsilonMHD
cd incompressible
wmake

#
 
