#!/bin/bash

# get date
DATE_TODAY=$(date +'%y%m%d')

# set installation location

# MY_RDS=       # set $MY_RDS here if required
DIR_NAME=nekMHD-v26_${DATE_TODAY}
NEKRS_GENERAL_DIR=${MY_RDS}/NekRS/MI300X
INSTALL_DIR=${NEKRS_GENERAL_DIR}/${DIR_NAME}

# Direct install script to the nekrs_mhd repo; set as required
# shouldn't change the name of the directory itself
NEKRS_MHD_DIR=${HOME}/nekMHD-v26

## Don't modify this script below this line

ORIGIN_DIR=$PWD

# Write NekRS profile

PROFILE_NAME=nekrs_mi300x_nekMHD_v26_${DATE_TODAY}_profile

echo "module purge" > $HOME/.$PROFILE_NAME
echo "module load rhel9/default-amdgpu" >> $HOME/.$PROFILE_NAME
echo "module load openmpi" >> $HOME/.$PROFILE_NAME
echo "export CC=mpicc" >> $HOME/.$PROFILE_NAME
echo "export CXX=mpicxx" >> $HOME/.$PROFILE_NAME
echo "export FC=mpifort" >> $HOME/.$PROFILE_NAME
echo "export HIPCXXFLAGS=\"-std=c++17\"" >> $HOME/.$PROFILE_NAME # fix for rocm 7.0 dropping c++14 support
echo "export NEKRS_HOME=$INSTALL_DIR/nekRS" >> $HOME/.$PROFILE_NAME
echo "export NEKRS_TOOLS=$INSTALL_DIR/build/3rd_party/nek5000/bin" >> $HOME/.$PROFILE_NAME

echo "export PATH=\${NEKRS_HOME}/bin:\${PATH}" >> $HOME/.$PROFILE_NAME
echo "export PATH=\${NEKRS_TOOLS}:\${PATH}" >> $HOME/.$PROFILE_NAME

echo "export NRS_RUN=$NEKRS_GENERAL_DIR/user_problems" >> $HOME/.$PROFILE_NAME
echo "alias nrs='cd \${NRS_RUN} && ls'" >> $HOME/.$PROFILE_NAME

# Load NekRS profile

source ~/.$PROFILE_NAME

# make directory
mkdir -p $INSTALL_DIR

# store details of build environment

mkdir $INSTALL_DIR/setup
cd $INSTALL_DIR/setup
module list > log.module_list
env > log.env
rocminfo > log.rocminfo
rocm-smi > log.rocm-smi
rocm-smi --showtopo > log.rocm-smi-topo

cp ~/.bashrc log.bashrc
cp ~/.bash_profile log.bash_profile
cp ~/.$PROFILE_NAME log.$PROFILE_NAME

# get NekRS source code

cd $INSTALL_DIR
cp -r $NEKRS_MHD_DIR source
cd source
git apply $ORIGIN_DIR/syncwarp.patch # syncwarp patch
cd $INSTALL_DIR

# build NekRS

cd $INSTALL_DIR/source

echo "++++++++++++++++++++++"
echo "+++ Building NekRS +++"
echo "++++++++++++++++++++++"

# remove user input requirements
sed -i s/'read -rsn1 key'/''/g build.sh

# run config
./build.sh -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/nekRS -DENABLE_HYPRE_GPU=on -DNEKRS_Fortran_FLAGS="-fuse-ld=bfd" 2>&1 | tee $INSTALL_DIR/setup/log.build

echo "++++++++++++++++++++++"
echo "++++ NekRS Built +++++"
echo "++++++++++++++++++++++"
