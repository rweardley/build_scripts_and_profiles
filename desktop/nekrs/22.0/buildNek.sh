#!/bin/bash

profile="nekrs_22-0_profile"	# NOTE: don't give the dot (.) here
dirname="22.0"
dir=$HOME/NekRS/$dirname

source ~/.$profile

cd $dir/build

env | tee log.env
cp ~/.bashrc log.bashrc
cp ~/.bash_profile log.bash_profile
cp ~/.$profile log.$profile

echo "+++++++++++++++++++++"
echo "+++ Run nrsconfig +++"
echo "+++++++++++++++++++++"

./nrsconfig 2>&1 | tee log.nrsconfig

echo "+++++++++++++++++++++"
echo "+++ Building NekRS ++"
echo "+++++++++++++++++++++"

cmake --build ./build --target install -j32 2>&1 | tee log.nrsbuild

echo "+++++++++++++++++++++"
echo "+++ NekRS Built +++++"
echo "+++++++++++++++++++++"

mv log.bashrc log.bash_profile log.$profile log.nrsconfig log.nrsbuild $dir/setup
