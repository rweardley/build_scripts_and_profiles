#!/bin/bash

PROFILE_NAME="nektools_profile"
NEKRS_GENERAL_DIR=${MY_RDS}/NekRS_test

echo "export NEK5000_TOOLS=$NEKRS_GENERAL_DIR/Nek5000/bin" > $HOME/.$PROFILE_NAME
echo "export PATH=\${PATH}:\${NEK5000_TOOLS}" >> $HOME/.$PROFILE_NAME

mkdir -p $NEKRS_GENERAL_DIR
cd $NEKRS_GENERAL_DIR
git clone https://github.com/Nek5000/Nek5000.git
cd Nek5000/tools
./maketools all