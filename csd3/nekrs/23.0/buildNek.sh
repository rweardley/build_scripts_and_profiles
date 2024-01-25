#!/bin/bash

profile="nekrs_23-0_profile"	# NOTE: don't give the dot (.) here
dirname="23.0"
dir=$MY_RDS/NekRS/$dirname

source ~/.$profile

cd $dir/build

env | tee log.env
cp ~/.bashrc log.bashrc
cp ~/.bash_profile log.bash_profile
cp ~/.$profile log.$profile

echo "++++++++++++++++++++++"
echo "+++ Building NekRS +++"
echo "++++++++++++++++++++++"

# remove user input requirements
sed -i s/'read -p "Press ENTER to continue or ctrl-c to cancel"'/''/g nrsconfig

# run config
CC=$CC CXX=$CXX FC=$FC ./nrsconfig -D CMAKE_INSTALL_PREFIX=$dir/nekRS 2>&1 | tee log.nrsconfig

echo "++++++++++++++++++++++"
echo "++++ NekRS Built +++++"
echo "++++++++++++++++++++++"

mv log.env log.bashrc log.bash_profile log.$profile log.nrsconfig $dir/setup
