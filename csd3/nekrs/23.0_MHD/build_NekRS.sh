#!/bin/bash

# set NekRS version
version_major=23
version_minor=0

# get date
DATE_TODAY=$(date +'%y%m%d')

# set installation location

# MY_RDS=       # set $MY_RDS here if required
DIR_NAME=MHD_${version_major}.${version_minor}_${DATE_TODAY}
NEKRS_GENERAL_DIR=${MY_RDS}/NekRS
INSTALL_DIR=${NEKRS_GENERAL_DIR}/${DIR_NAME}

# Direct install script to the nekrs_mhd repo; set as required
# shouldn't change the name of the directory itself
NEKRS_MHD_DIR=${HOME}/nekRS_MHD_code

## Don't modify this script below this line

# Write NekRS profile

PROFILE_NAME=nekrs_MHD_${version_major}-${version_minor}_${DATE_TODAY}_profile

echo "module purge" > $HOME/.$PROFILE_NAME
echo "module load rhel8/default-amp" >> $HOME/.$PROFILE_NAME
echo "export CC=mpicc" >> $HOME/.$PROFILE_NAME
echo "export CXX=mpic++" >> $HOME/.$PROFILE_NAME
echo "export FC=mpif77" >> $HOME/.$PROFILE_NAME
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
env > log.env
cp ~/.bashrc log.bashrc
cp ~/.bash_profile log.bash_profile
cp ~/.$PROFILE_NAME log.$PROFILE_NAME

# get NekRS source code

cd $INSTALL_DIR
cp -r $NEKRS_MHD_DIR .

# build NekRS

cd $INSTALL_DIR/nekRS_MHD_code

echo "++++++++++++++++++++++"
echo "+++ Building NekRS +++"
echo "++++++++++++++++++++++"

# remove user input requirements
sed -i s/'read -p "Press ENTER to continue or ctrl-c to cancel"'/''/g nrsconfig

# run config (includes building GPU-enabled Hypre, only works for Nvidia GPU currently)
CC=$CC CXX=$CXX FC=$FC ./nrsconfig -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/nekRS -DENABLE_HYPRE_GPU=on 2>&1 | tee $INSTALL_DIR/setup/log.nrsconfig

echo "++++++++++++++++++++++"
echo "++++ NekRS Built +++++"
echo "++++++++++++++++++++++"
