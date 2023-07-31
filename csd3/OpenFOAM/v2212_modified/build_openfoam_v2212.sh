#!/bin/bash

openfoam_dir="$HOME/OpenFOAM"
openfoam_version="v2212"
openfoam_profile_name="v2212"
petsc_version="3.18.2"

# don't change things below here

mkdir $openfoam_dir
cd $openfoam_dir

# get OpenFOAM
wget https://dl.openfoam.com/source/$openfoam_version/OpenFOAM-$openfoam_version.tgz
tar -xvf OpenFOAM-$openfoam_version.tgz
rm OpenFOAM-$openfoam_version.tgz
cd OpenFOAM-$openfoam_version

# get third party tools
wget https://dl.openfoam.com/source/$openfoam_version/ThirdParty-$openfoam_version.tgz
tar -xvf ThirdParty-$openfoam_version.tgz
rm ThirdParty-$openfoam_version.tgz
mv ThirdParty-v2212 ThirdParty

# get PETSc
cd ThirdParty/sources
git clone -b release https://gitlab.com/petsc/petsc.git petsc
mv petsc petsc-$petsc_version
cd petsc-$petsc_version
git pull
git checkout v$petsc_version

# write dot profile
echo "module purge" > ~/.openfoam_"$openfoam_profile_name"_profile
echo "module load rhel8/slurm" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "module load rhel8/global" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "module load dot singularity" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "module load cuda/11.4 vgl" >> ~/.openfoam_"$openfoam_profile_name"_profile
echo "module load gcc/9 openmpi/gcc/9.3/4.0.4" >> ~/.openfoam_"$openfoam_profile_name"_profile

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

# this is a hacky fix
# echo "export LD_LIBRARY_PATH=/usr/local/software/spack/spack-rhel8-20210927/opt/spack/linux-centos8-x86_64_v3/gcc-11.2.0/gcc-11.2.0-en35jayfoxmdht4xqdfb7ggaqq5rzq5b/lib64:\$LD_LIBRARY_PATH" >> ~/.openfoam_"$openfoam_profile_name"_profile


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

