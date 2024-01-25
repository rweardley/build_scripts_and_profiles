#!/bin/bash

cd $MY_RDS/NekRS/22.0/build

env | tee log.env
module list | tee log.module_list
cp ~/.bashrc log.bashrc
cp ~/.bash_profile log.bash_profile

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

mv log.module_list log.bashrc log.bash_profile log.nrsconfig log.nrsbuild $MY_RDS/NekRS/22.0/setup
