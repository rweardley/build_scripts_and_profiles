#!/bin/bash

# set installation location

DIR_NAME=nekMHD
NEKRS_GENERAL_DIR=${HOME}/NekRS
INSTALL_DIR=${NEKRS_GENERAL_DIR}/${DIR_NAME}

## Don't modify this script below this line

# Write NekRS profile

PROFILE_NAME=nekrs_nekMHD_profile

echo "export CC=mpicc" > $HOME/.$PROFILE_NAME
echo "export CXX=mpic++" >> $HOME/.$PROFILE_NAME
echo "export FC=mpif77" >> $HOME/.$PROFILE_NAME
echo "export PATH=\${PATH}:/usr/local/cuda-12/bin" >> $HOME/.$PROFILE_NAME
echo "export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:/usr/local/cuda-12/lib64" >> $HOME/.$PROFILE_NAME
echo "export NEKRS_HOME=$INSTALL_DIR/nekRS" >> $HOME/.$PROFILE_NAME

echo "export PATH=\${NEKRS_HOME}/bin:\${PATH}" >> $HOME/.$PROFILE_NAME

echo "export NRS_RUN=$NEKRS_GENERAL_DIR/user_problems" >> $HOME/.$PROFILE_NAME
echo "alias nrs='cd \${NRS_RUN} && ls'" >> $HOME/.$PROFILE_NAME
echo "alias nekrun='mpirun --mca osc ucx -np 1 nekrs --setup'" >> $HOME/.$PROFILE_NAME

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
git clone git@github.com:misunmin/nekMHD.git
cd nekMHD
git checkout elliptic-var-coeff-field-fix
cd $INSTALL_DIR
mv nekMHD source

# build NekRS

cd $INSTALL_DIR/source

echo "++++++++++++++++++++++"
echo "+++ Building NekRS +++"
echo "++++++++++++++++++++++"

# remove user input requirements
sed -i s/'read -rsn1 key'/''/g build.sh

# run config
./build.sh -D CMAKE_INSTALL_PREFIX=$INSTALL_DIR/nekRS 2>&1 | tee $INSTALL_DIR/setup/log.build

echo "++++++++++++++++++++++"
echo "++++ NekRS Built +++++"
echo "++++++++++++++++++++++"
