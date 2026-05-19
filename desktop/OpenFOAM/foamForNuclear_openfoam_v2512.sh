OPENFOAM_VERSION=2512
PROFILE_NAME="openfoam_v${OPENFOAM_VERSION}_foamForNuclear_profile"
OPENFOAM_DIR="/usr/lib/openfoam/openfoam${OPENFOAM_VERSION}"
BUILD_CORES=4

echo $OPENFOAM_DIR

if [[ -d $OPENFOAM_DIR ]]; then
    echo "OpenFOAM ${OPENFOAM_VERSION} found"
    echo "source ${OPENFOAM_DIR}/etc/bashrc" > ~/.$PROFILE_NAME

    source ~/.$PROFILE_NAME

    cd $WM_PROJECT_USER_DIR

    # Clone the repo
    git clone --recursive https://gitlab.com/foamForNuclear/foamForNuclear.git

    # Compile the foamForNuclear project and build the foamForNuclear Python API
    cd foamForNuclear
    python -m venv venv
    source venv/bin/activate
    ./Allwmake -j$BUILD_CORES --api 2>&1 | tee log.allwmake
    
    # Install fluidfoam; used for tutorials
    pip install fluidfoam

    # Add python environment to profile
    echo "source \${WM_PROJECT_USER_DIR}/foamForNuclear/venv/bin/activate" >> ~/.$PROFILE_NAME

    echo "Done: load foamForNuclear with \`source ~/.$PROFILE_NAME\`"
    
else
    echo "Failed: first install OpenFOAM v2512 as follows:"
    echo "curl -s https://dl.openfoam.com/add-debian-repo.sh | sudo bash"
    echo "sudo apt-get update"
    echo "sudo apt-get install openfoam2512-default"
fi