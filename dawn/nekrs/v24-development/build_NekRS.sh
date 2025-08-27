#!/bin/bash

# get date
DATE_TODAY=$(date +'%y%m%d')

# set installation location

# MY_RDS=       # set $MY_RDS here if required
DIR_NAME=v24-dev_${DATE_TODAY}
NEKRS_GENERAL_DIR=${MY_RDS}/NekRS/DAWN
INSTALL_DIR=${NEKRS_GENERAL_DIR}/${DIR_NAME}

## Don't modify this script below this line

ORIGIN_DIR=$PWD

# Write NekRS profile

PROFILE_NAME=nekrs_dawn_v24-dev_${DATE_TODAY}_profile

echo "export MPI_MODULE=$MPI_MODULE" > $HOME/.$PROFILE_NAME
echo "module purge" >> $HOME/.$PROFILE_NAME
echo "module load rhel9/default-dawn" >> $HOME/.$PROFILE_NAME
echo "module load intel-oneapi-compilers" >> $HOME/.$PROFILE_NAME
echo "module load intel-oneapi-mpi" >> $HOME/.$PROFILE_NAME
echo "export CC=mpicc" >> $HOME/.$PROFILE_NAME
echo "export CXX=mpicxx" >> $HOME/.$PROFILE_NAME
echo "export FC=mpifc" >> $HOME/.$PROFILE_NAME
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
sycl-ls > log.sycl-ls
xpu-smi > log.xpu-smi
xpu-smi topology -m > log.xpu-smi-topo


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
#sed -i s/'read -p "Press ENTER to continue or ctrl-c to cancel"'/''/g build.sh
#sed -i s/'echo -e "\033[32mPlease check the summary above carefully and press ENTER to continue or ctrl-c to cancel\033[m"'/''/g build.sh
#sed -i s/'echo -e "\033[32mPlease check the summary above carefully and press ENTER to continue or ctrl-c to cancel\033[m"'/''/g build.sh
sed -i s/'read -rsn1 key'/''/g build.sh

# run config
./build.sh -D CMAKE_INSTALL_PREFIX=$INSTALL_DIR/nekRS 2>&1 | tee $INSTALL_DIR/setup/log.build

echo "++++++++++++++++++++++"
echo "++++ NekRS Built +++++"
echo "++++++++++++++++++++++"

if [ -f $ORIGIN_DIR/nrsqsub_dawn ]; then
    echo "Found script nrsqsub_dawn"
    echo "Installing script to \$NEKRS_HOME/bin"
    cp $ORIGIN_DIR/nrsqsub_dawn $INSTALL_DIR/nekRS/bin
    chmod 744 $INSTALL_DIR/nekRS/bin/nrsqsub_dawn
fi
if [ -f $ORIGIN_DIR/nrsqsub_dawn_modified ]; then
    echo "Found script nrsqsub_dawn_modified"
    echo "Installing script to \$NEKRS_HOME/bin"
    cp $ORIGIN_DIR/nrsqsub_dawn_modified $INSTALL_DIR/nekRS/bin
    chmod 744 $INSTALL_DIR/nekRS/bin/nrsqsub_dawn_modified
fi

echo "++++++++++++++++++++++"
echo "++++ All Finished ++++"
echo "++++++++++++++++++++++"
