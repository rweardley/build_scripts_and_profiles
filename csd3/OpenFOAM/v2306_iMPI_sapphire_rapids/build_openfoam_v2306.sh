#!/bin/bash

openfoam_dir="$HOME/OpenFOAM"
openfoam_version="v2306"
openfoam_profile_name="v2306_sapphire"

# don't change things below here

mkdir -p $openfoam_dir
cd $openfoam_dir

# get OpenFOAM
wget https://dl.openfoam.com/source/$openfoam_version/OpenFOAM-$openfoam_version.tgz
tar -xvf OpenFOAM-$openfoam_version.tgz
rm OpenFOAM-$openfoam_version.tgz
cd OpenFOAM-$openfoam_version

# set OpenFOAM preferences for Intel compilers & MPI

echo "export WM_COMPILER_TYPE=system" > $openfoam_dir/OpenFOAM-$openfoam_version/etc/prefs.sh
echo "export WM_COMPILER=Icc" >> $openfoam_dir/OpenFOAM-$openfoam_version/etc/prefs.sh
echo "export WM_MPLIB=INTELMPI" >> $openfoam_dir/OpenFOAM-$openfoam_version/etc/prefs.sh

# get third party tools
wget https://dl.openfoam.com/source/$openfoam_version/ThirdParty-$openfoam_version.tgz
tar -xvf ThirdParty-$openfoam_version.tgz
rm ThirdParty-$openfoam_version.tgz
mv ThirdParty-$openfoam_version ThirdParty

# write dot profile
echo "module purge" > ~/.openfoam_"$openfoam_profile_name"_profile
echo "module load rhel8/default-sar" >> ~/.openfoam_"$openfoam_profile_name"_profile

echo "source $openfoam_dir/OpenFOAM-$openfoam_version/etc/bashrc" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export CC=mpicc" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export CXX=mpicxx" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export F90=mpif90" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export F77=mpif77" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export FC=mpif90" >> ~/.openfoam_"$openfoam_profile_name"_profile

# source basic OpenFOAM bashrc requirements
source ~/.openfoam_"$openfoam_profile_name"_profile
cd $WM_PROJECT_DIR

foamSystemCheck

# start building

./Allwmake -j -s -q -l	# make using all available cores, reduced output, queuing and logs

foamInstallationTest
