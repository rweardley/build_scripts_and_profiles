#!/bin/bash

# get date
DATE_TODAY=$(date +'%y%m%d')

# set installation location

# MY_RDS=       # set $MY_RDS here if required
DIR_NAME=aurora-dev_${DATE_TODAY}
NEKRS_GENERAL_DIR=${MY_RDS}/NekRS/MI300X
INSTALL_DIR=${NEKRS_GENERAL_DIR}/${DIR_NAME}

## Don't modify this script below this line

ORIGIN_DIR=$PWD

# Write NekRS profile

PROFILE_NAME=nekrs_mi300x_aurora-mhd_${DATE_TODAY}_profile

echo "module purge" > $HOME/.$PROFILE_NAME
echo "module load rhel9/default-amdgpu" >> $HOME/.$PROFILE_NAME
echo "export CC=mpicc" >> $HOME/.$PROFILE_NAME #
echo "export CXX=mpicxx" >> $HOME/.$PROFILE_NAME #
echo "export FC=mpifc" >> $HOME/.$PROFILE_NAME #
echo "export I_MPI_CC=hipcc" >> $HOME/.$PROFILE_NAME #
echo "export I_MPI_CXX=hipcc" >> $HOME/.$PROFILE_NAME #
echo "export I_MPI_FC=amdflang" >> $HOME/.$PROFILE_NAME # or hipfc
echo "export CMAKE_PREFIX_PATH=/opt/rocm:\$CMAKE_PREFIX_PATH" >> $HOME/.$PROFILE_NAME
echo "export ROCM_HOME=/opt/rocm" >> $HOME/.$PROFILE_NAME
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
git clone https://github.com/Nek5000/nekRS.git
cd $INSTALL_DIR/nekRS
git checkout v24-development
cd $INSTALL_DIR
mv nekRS source

# build NekRS

cd $INSTALL_DIR/source

echo "++++++++++++++++++++++"
echo "+++ Building NekRS +++"
echo "++++++++++++++++++++++"

# remove user input requirements
sed -i s/'read -rsn1 key'/''/g build.sh

# run config
./build.sh -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/nekRS -DENABLE_HYPRE_GPU=on 2>&1 | tee $INSTALL_DIR/setup/log.build

echo "++++++++++++++++++++++"
echo "++++ NekRS Built +++++"
echo "++++++++++++++++++++++"
