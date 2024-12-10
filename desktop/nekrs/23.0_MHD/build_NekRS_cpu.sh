#!/bin/bash

# set NekRS version
version_major=23
version_minor=0

# set installation location

DIR_NAME=MHD_${version_major}.${version_minor}
NEKRS_GENERAL_DIR=${HOME}/Programs/NekRS
INSTALL_DIR=${NEKRS_GENERAL_DIR}/${DIR_NAME}

## Don't modify this script below this line

# Write NekRS profile

PROFILE_NAME=nekrs_MHD_${version_major}-${version_minor}_profile

echo "export CC=mpicc" > $HOME/.$PROFILE_NAME
echo "export CXX=mpic++" >> $HOME/.$PROFILE_NAME
echo "export FC=mpif77" >> $HOME/.$PROFILE_NAME
#echo "export PATH=\${PATH}:/usr/local/cuda-11.8/bin" >> $HOME/.$PROFILE_NAME
#echo "export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:/usr/local/cuda-11.8/lib64" >> $HOME/.$PROFILE_NAME
echo "export NEKRS_HOME=$INSTALL_DIR/nekRS" >> $HOME/.$PROFILE_NAME

echo "export PATH=\${NEKRS_HOME}/bin:\${PATH}" >> $HOME/.$PROFILE_NAME

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
git clone git@github.com:guo-yichen/nekRS_MHD_code.git

# build NekRS

cd $INSTALL_DIR/nekRS_MHD_code

echo "++++++++++++++++++++++"
echo "+++ Building NekRS +++"
echo "++++++++++++++++++++++"

# remove user input requirements
sed -i s/'read -p "Press ENTER to continue or ctrl-c to cancel"'/''/g nrsconfig

# run config
CC=$CC CXX=$CXX FC=$FC ./nrsconfig -D CMAKE_INSTALL_PREFIX=$INSTALL_DIR/nekRS 2>&1 | tee $INSTALL_DIR/setup/log.nrsconfig

echo "++++++++++++++++++++++"
echo "++++ NekRS Built +++++"
echo "++++++++++++++++++++++"
