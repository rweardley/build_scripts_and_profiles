# Download the CUDA 12.2 user-space installer
wget https://developer.download.nvidia.com/compute/cuda/12.2.0/local_installers\
/cuda_12.2.0_535.54.03_linux.run

# Make the installer executable
chmod +x cuda_12.2.0_535.54.03_linux.run

# Install the CUDA 12.2 toolkit locally without drivers or sudo
./cuda_12.2.0_535.54.03_linux.run \
  --silent \
  --toolkit \
  --toolkitpath=$HOME/Programs/cuda/cuda-12.2 \
  --no-drm \
  --override

# Clean up
rm cuda_12.2.0_535.54.03_linux.run