#!/bin/bash

# set installation location

DIR_NAME=v26
NEKRS_GENERAL_DIR=${HOME}/NekRS
INSTALL_DIR=${NEKRS_GENERAL_DIR}/${DIR_NAME}

## Don't modify this script below this line

# Write NekRS profile

PROFILE_NAME=nekrs_v26_profile

# Load NekRS profile

source ~/.$PROFILE_NAME

# rebuild NekRS

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
