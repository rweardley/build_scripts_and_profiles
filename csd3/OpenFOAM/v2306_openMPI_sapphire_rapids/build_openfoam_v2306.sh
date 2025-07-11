#!/bin/bash

OPENFOAM_DIR="$MY_RDS/OpenFOAM/builds/OpenFOAM-OpenMPI"
OPENFOAM_VERSION="v2306"
OPENFOAM_PROFILE_NAME="${OPENFOAM_VERSION}_OpenMPI_sapphire"

# Don't change things below here

mkdir -p $OPENFOAM_DIR
cd $OPENFOAM_DIR || { echo "$OPENFOAM_DIR does not exist"; exit; }

# Get OpenFOAM
wget https://dl.openfoam.com/source/$OPENFOAM_VERSION/OpenFOAM-$OPENFOAM_VERSION.tgz
tar -xvf OpenFOAM-$OPENFOAM_VERSION.tgz
rm OpenFOAM-$OPENFOAM_VERSION.tgz
cd OpenFOAM-$OPENFOAM_VERSION || { echo "OpenFOAM-$OPENFOAM_VERSION does not exist"; exit; }

# Set OpenFOAM preferences for Intel compilers & MPI
#PREFS_FILE="$OPENFOAM_DIR/OpenFOAM-$OPENFOAM_VERSION/etc/prefs.sh"

#echo "export WM_COMPILER_TYPE=system" > $PREFS_FILE
#echo "export WM_COMPILER=Icc" >> $PREFS_FILE
#echo "export WM_MPLIB=INTELMPI" >> $PREFS_FILE

# Get third party tools
wget https://dl.openfoam.com/source/$OPENFOAM_VERSION/ThirdParty-$OPENFOAM_VERSION.tgz
tar -xvf ThirdParty-$OPENFOAM_VERSION.tgz
rm ThirdParty-$OPENFOAM_VERSION.tgz
mv ThirdParty-$OPENFOAM_VERSION ThirdParty

# Write .profile for OpenFOAM
PROFILE_FILE="$HOME/.openfoam_${OPENFOAM_PROFILE_NAME}_profile"

echo "module purge" > $PROFILE_FILE
echo "module load rhel9/default-sar" >> $PROFILE_FILE
echo "source ~/.openmpi_profile" >> $PROFILE_FILE
echo "source $OPENFOAM_DIR/OpenFOAM-$OPENFOAM_VERSION/etc/bashrc" >> $PROFILE_FILE
echo "export CC=mpicc" >> $PROFILE_FILE
echo "export CXX=mpicxx" >> $PROFILE_FILE
echo "export F90=mpif90" >> $PROFILE_FILE
echo "export F77=mpif77" >> $PROFILE_FILE
echo "export FC=mpif90" >> $PROFILE_FILE

# Source the OpenFOAM profile
source $PROFILE_FILE

# Move to the OpenFOAM project directory
cd $WM_PROJECT_DIR || { echo "$WM_PROJECT_DIR does not exist"; exit; }

# Check system compatibility
foamSystemCheck

# Start building OpenFOAM
./Allwmake -j -s -q -l  # Use all available cores, reduced output, queuing and logs

# Verify installation
foamInstallationTest
