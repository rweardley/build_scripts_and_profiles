#!/bin/bash

# get date
DATE_TODAY=$(date +'%y%m%d')

# set installation location

MY_HOME=${HOME}
DIR_NAME=next_${DATE_TODAY}_custom_ompi
NEKRS_GENERAL_DIR=${MY_HOME}/NekRS
INSTALL_DIR=${NEKRS_GENERAL_DIR}/${DIR_NAME}

# set location of cmake binary (module not available on cosma mi300x)
CMAKE_VERSION="3.31.6"
CMAKE_BIN_DIR=${HOME}/cmake/cmake-${CMAKE_VERSION}-linux-x86_64/bin

## Don't modify this script below this line

ORIGIN_DIR=$PWD

# Write NekRS profile

PROFILE_NAME=nekrs_next_${DATE_TODAY}_custom_ompi_profile

echo "module load hipcc/6.3amd" > $MY_HOME/.$PROFILE_NAME
#echo "module load openmpi" >> $MY_HOME/.$PROFILE_NAME
#echo "module load ucx" >> $MY_HOME/.$PROFILE_NAME
echo "source ~/.openmpi_profile" >> $MY_HOME/.$PROFILE_NAME
echo "export CC=mpicc" >> $MY_HOME/.$PROFILE_NAME
echo "export CXX=mpic++" >> $MY_HOME/.$PROFILE_NAME
echo "export FC=mpif77" >> $MY_HOME/.$PROFILE_NAME
echo "export OMPI_CC=hipcc" >> $MY_HOME/.$PROFILE_NAME
echo "export OMPI_CXX=hipcc" >> $MY_HOME/.$PROFILE_NAME
echo "export CMAKE_PREFIX_PATH=/opt/rocm:\$CMAKE_PREFIX_PATH" >> $MY_HOME/.$PROFILE_NAME
echo "export ROCM_HOME=/opt/rocm" >> $MY_HOME/.$PROFILE_NAME
echo "export NEKRS_HOME=$INSTALL_DIR/nekRS" >> $MY_HOME/.$PROFILE_NAME
echo "export PATH=\${NEKRS_HOME}/bin:\${PATH}" >> $MY_HOME/.$PROFILE_NAME
echo "export PATH=${CMAKE_BIN_DIR}:\${PATH}" >> $MY_HOME/.$PROFILE_NAME
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
git checkout next
cd $INSTALL_DIR
mv nekRS source

# build NekRS

cd $INSTALL_DIR/source

echo "++++++++++++++++++++++"
echo "+++ Building NekRS +++"
echo "++++++++++++++++++++++"

# remove user input requirements

# next
sed -i s/'read -p         "Press ENTER to continue with CC=$CC CXX=$CXX FC=$FC or ctrl-c to cancel"'/''/g build.sh
sed -i s/'echo -e "\033[32mPlease check the summary above carefully and press ENTER to continue or ctrl-c to cancel\033[m"'/''/g build.sh
sed -i s/'read -rsn1 key  '/''/g build.sh

# run config
./build.sh -D CMAKE_INSTALL_PREFIX=$INSTALL_DIR/nekRS 2>&1 | tee $INSTALL_DIR/setup/log.build

echo "++++++++++++++++++++++"
echo "++++ NekRS Built +++++"
echo "++++++++++++++++++++++"
