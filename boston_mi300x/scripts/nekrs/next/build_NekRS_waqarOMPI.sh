#!/bin/bash

# get date
DATE_TODAY=$(date +'%y%m%d')

# set installation location

MY_HOME=${HOME}/rupert
DIR_NAME=wompi_next_${DATE_TODAY}
NEKRS_GENERAL_DIR=${MY_HOME}/NekRS
INSTALL_DIR=${NEKRS_GENERAL_DIR}/${DIR_NAME}

## Don't modify this script below this line

ORIGIN_DIR=$PWD

# Write NekRS profile

PROFILE_NAME=nekrs_next_${DATE_TODAY}_profile

echo "source $MY_HOME/.openmpi_waqar_profile" > $MY_HOME/.$PROFILE_NAME
echo "export CC=mpicc" >> $MY_HOME/.$PROFILE_NAME
echo "export CXX=mpic++" >> $MY_HOME/.$PROFILE_NAME
echo "export FC=mpif77" >> $MY_HOME/.$PROFILE_NAME
echo "export OMPI_CC=hipcc" >> $MY_HOME/.$PROFILE_NAME
echo "export OMPI_CXX=hipcc" >> $MY_HOME/.$PROFILE_NAME
echo "export CMAKE_PREFIX_PATH=/opt/rocm:\$CMAKE_PREFIX_PATH" >> $MY_HOME/.$PROFILE_NAME
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
git checkout next # as of 14th Nov, d0f3cff (fails, GPU-aware MPI disabled)
#git checkout a869ca6920b79456956668a990a364bcb1e35707 # 17th Jun (fortran compiler doesn't work)
#git checkout b2781c2ce25756bc806e9e02cf795413a1035ce4 # 22nd Sep (fortran compiler doesn't work)
git checkout dc8679e127639f542ece5bd90273c61b36ab3e99 # 1st Oct (Fails for same reason as next but GPU-aware MPI enabled, yay)
### for the error, see ../NekRS/next_241114/source/build/nek5000_deps-prefix/src/nek5000_deps-build/build.log
cd $INSTALL_DIR
mv nekRS source

# build NekRS

cd $INSTALL_DIR/source

echo "++++++++++++++++++++++"
echo "+++ Building NekRS +++"
echo "++++++++++++++++++++++"

# remove user input requirements

# v23
sed -i s/'read -p "Press ENTER to continue or ctrl-c to cancel"'/''/g nrsconfig

# next
sed -i s/'read -p "Press ENTER to continue or ctrl-c to cancel"'/''/g build.sh
sed -i s/'echo -e "\033[32mPlease check the summary above carefully and press ENTER to continue or ctrl-c to cancel\033[m"'/''/g build.sh
sed -i s/'read -rsn1 key  '/''/g build.sh

# run config
./build.sh -D CMAKE_INSTALL_PREFIX=$INSTALL_DIR/nekRS 2>&1 | tee $INSTALL_DIR/setup/log.build

echo "++++++++++++++++++++++"
echo "++++ NekRS Built +++++"
echo "++++++++++++++++++++++"
