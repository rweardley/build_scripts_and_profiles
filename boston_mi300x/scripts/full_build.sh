#!/bin/bash

scripts_dir=`pwd`

cd mpich
./build_mpich.sh 2>&1 | tee log.build_mpich
cd $scripts_dir

#cd openmpi
#./build_openmpi.sh 2>&1 | tee log.build_openmpi
#cd $scripts_dir

cd nekrs/next
#cd nekrs/23.0
./build_NekRS.sh 2>&1 | tee log.build_nekrs
#./build_NekRS_waqarOMPI.sh 2>&1 | tee log.build_nekrs_wompi
cd $scripts_dir
