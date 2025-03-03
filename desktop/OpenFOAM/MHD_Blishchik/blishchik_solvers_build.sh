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
cd potentialFvPatchScalarField
# start: fixes which should be resolved with changes to the main repo (included files which break the installation)
rm lnInclude Make/{files~,linux64GccDPInt64Opt}
# end
wmake
cd ..
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
 
