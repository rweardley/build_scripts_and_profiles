#!/bin/bash

# Remember to set .openfoam9_profile first

cd $HOME

if [[ ! -d OpenFOAM ]]
then
    	mkdir -p OpenFOAM
fi
cd OpenFOAM

git clone https://github.com/OpenFOAM/OpenFOAM-9.git
git clone https://github.com/OpenFOAM/ThirdParty-9.git

source ~/.openfoam9_profile

cd ThirdParty-9
./Allwmake 2>&1 | tee log.MakeThirdParty

cd ..

cd OpenFOAM-9
./Allwmake -j 2>&1 | tee log.MakeOpenFOAM
