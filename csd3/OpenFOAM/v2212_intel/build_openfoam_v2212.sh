#!/bin/bash

openfoam_dir="$HOME/OpenFOAM"
openfoam_version="v2212"
openfoam_profile_name="v2212"
petsc_version="3.18.2"

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

# get PETSc
cd ThirdParty/sources
git clone -b release https://gitlab.com/petsc/petsc.git petsc
mv petsc petsc-$petsc_version
cd petsc-$petsc_version
git pull
git checkout v$petsc_version

# write dot profile
echo "module purge" > ~/.openfoam_"$openfoam_profile_name"_profile
echo "module load rhel8/default-icl" >> ~/.openfoam_"$openfoam_profile_name"_profile

echo "source $openfoam_dir/OpenFOAM-$openfoam_version/etc/bashrc" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export CC=mpicc" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export CXX=mpicxx" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export F90=mpif90" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export F77=mpif77" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export FC=mpif90" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export PETSC_ARCH_PATH=$openfoam_dir/OpenFOAM-$openfoam_version/ThirdParty/sources/petsc-$petsc_version" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export PETSC_DIR=\$PETSC_ARCH_PATH" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export PETSC_ARCH=DPInt32" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "export LD_LIBRARY_PATH=\$PETSC_DIR/\$PETSC_ARCH/lib:\$LD_LIBRARY_PATH" >> ~/.openfoam_"$openfoam_profile_name"_profile

# source basic OpenFOAM bashrc requirements
source ~/.openfoam_"$openfoam_profile_name"_profile
cd $WM_PROJECT_DIR

foamSystemCheck

# start building

./Allwmake -j -s -q -l	# make using all available cores, reduced output, queuing and logs

# update bashrc
source ~/.openfoam_"$openfoam_profile_name"_profile
foamInstallationTest

# build PETSc

cd ThirdParty
./makePETSC -- --download-f2cblaslapack CC=$CC CXX=$CXX F90=$F90 F77=$F77 FC=$FC --CXXOPTFLAGS="-O3" --COPTFLAGS="-O3" --FOPTFLAGS="-O3"

cd $WM_PROJECT_DIR/modules/external-solver
./Allwmake -prefix=openfoam

