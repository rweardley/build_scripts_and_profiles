Build process (this assumes prerequisites are met e.g. cmake, CUDA, GNU compilers, MPI):

1) cd to ~/NekRS (create if it doesn't exist)
2) make a directory for the NekRS version, e.g. 22.0, public-nekrs etc
3) Clone NekRS source within that directory
4) Rename source directory to "build"
	- Note, if you want to select a particular tag, run `git tag` to list all tags, then `git checkout <branch-name>` (will get detached HEAD)
5) Make directory "setup" and move buildNek.sh script (in this repo) there
6) Adjust buildNek.sh script to suit the installation
7) Adjust build/nrsconfig to suit the installation (set install directory as ~/NekRS/<version>/nekRS, and e.g. set CUDA on/off etc)
8) Write .nekrs_<version>_profile (examples in this repo), point to it in setup/buildNek.sh
9) from ~/NekRS/<version>, run ./setup/buildNek.sh

To install Nek5000 tools, cd to ~/NekRS, then run:

```
git clone https://github.com/Nek5000/Nek5000.git
cd Nek5000/tools
./maketools all
```

To install the prerequisites for a CUDA NekRS build on Ubuntu 22.04 (all versions should be up to date, but won't be with 20.04):
```
sudo apt install build-essential 	# for GNU C/C++ compilers and make
sudo apt install gfortran		# for GNU Fortran compilers
sudo apt install openmpi-bin		# for MPI
sudo apt install mpich			# for a different version of MPI
sudo apt install cmake			# for cmake
# sudo apt install nvidia-cuda-toolkit	# for CUDA # NOTE: Found that this version doesn't work properly
```
Also need to install CUDA, suggest using cuda-12.0 for NekRS v22
Full CUDA installation instructions can be found here: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html

```
sudo apt-key del 7fa2af80
https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb
sudo apt-get update
sudo apt-get install cuda
sudo apt-get install nvidia-gds # may not be needed
sudo reboot
```

If dependencies are still missing and NekRS won't build, try some of these
```
sudo apt-get install linux-generic libmpich-dev libopenmpi-dev
```
