#!/bin/bash

# Note: this build doesn't work,
# because NekRS v23 uses hipProps.gcnArch
# which was replaced with gcnArchName in ROCm 6.0
# So, need to use a "next" branch of NekRS

# set NekRS version

version_major=23
version_minor=0

# set installation location

MY_HOME=${HOME}/rupert
DIR_NAME=${version_major}.${version_minor}
NEKRS_GENERAL_DIR=${MY_HOME}/NekRS
INSTALL_DIR=${NEKRS_GENERAL_DIR}/${DIR_NAME}

## Don't modify this script below this line

ORIGIN_DIR=$PWD

# Write NekRS profile

PROFILE_NAME=nekrs_${version_major}-${version_minor}_profile

echo "source $MY_HOME/.mpich_profile" > $MY_HOME/.$PROFILE_NAME
echo "export CC=mpicc" >> $MY_HOME/.$PROFILE_NAME
echo "export CXX=mpic++" >> $MY_HOME/.$PROFILE_NAME
echo "export FC=mpif77" >> $MY_HOME/.$PROFILE_NAME
echo "export CMAKE_PREFIX_PATH=/opt/rocm:$CMAKE_PREFIX_PATH" >> $MY_HOME/.$PROFILE_NAME
echo "export ROCM_HOME=/opt/rocm" >> $MY_HOME/.$PROFILE_NAME
echo "export NEKRS_HOME=$INSTALL_DIR/nekRS" >> $MY_HOME/.$PROFILE_NAME
echo "export PATH=\${NEKRS_HOME}/bin:\${PATH}" >> $MY_HOME/.$PROFILE_NAME
echo "export NRS_RUN=$NEKRS_GENERAL_DIR/user_problems" >> $MY_HOME/.$PROFILE_NAME
echo "alias nrs='cd \${NRS_RUN} && ls'" >> $MY_HOME/.$PROFILE_NAME

# Load NekRS profile

source $MY_HOME/.$PROFILE_NAME

# make directory
mkdir -p $INSTALL_DIR

# store details of build environment

mkdir $INSTALL_DIR/setup
cd $INSTALL_DIR/setup
env > log.env
cp ~/.bashrc log.bashrc
cp ~/.bash_profile log.bash_profile
cp $MY_HOME/.$PROFILE_NAME log.$PROFILE_NAME

# get NekRS source code

cd $INSTALL_DIR
git clone https://github.com/Nek5000/nekRS.git
cd $INSTALL_DIR/nekRS
git checkout v$version_major.$version_minor
cd $INSTALL_DIR
mv nekRS source

# build NekRS

cd $INSTALL_DIR/source

echo "++++++++++++++++++++++"
echo "+++ Building NekRS +++"
echo "++++++++++++++++++++++"

# remove user input requirements

sed -i s/'read -p "Press ENTER to continue or ctrl-c to cancel"'/''/g nrsconfig

# run config
./nrsconfig -D CMAKE_INSTALL_PREFIX=$INSTALL_DIR/nekRS 2>&1 | tee $INSTALL_DIR/setup/log.nrsconfig

echo "++++++++++++++++++++++"
echo "++++ NekRS Built +++++"
echo "++++++++++++++++++++++"
