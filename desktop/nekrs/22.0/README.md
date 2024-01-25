Build process:

0) Set up prerequisites
1) cd to ~/NekRS (create if it doesn't exist)
2) make a directory for the NekRS version, e.g. 22.0, public-nekrs etc
3) Clone NekRS source within that directory
4) Rename source directory to "build"
	- Note, if you want to select a particular tag, run `git tag` to list all tags, then `git checkout <branch-name>` (will get detached HEAD)
5) Make directory "setup" and move buildNek.sh script (in this repo) there
6) Adjust buildNek.sh script to suit the installation
7) Adjust build/nrsconfig to suit the installation (set install directory as ~/NekRS/<version>/nekRS, and e.g. set CUDA on/off etc)
8) Write .nekrs_<version>_profile (examples in this repo, note it will be hidden due to .), point to it in setup/buildNek.sh
9) from ~/NekRS/<version>, run ./setup/buildNek.sh

To install Nek5000 tools, cd to ~/NekRS, then run:

```
git clone https://github.com/Nek5000/Nek5000.git
cd Nek5000/tools
./maketools all
```

To install the prerequisites for a CUDA NekRS build on Ubuntu 20.04:

1) GNU Compilers:
1.1) `sudo apt-get update`
1.2) `sudo apt-get install build-essential`
1.3) Check gcc compiler version: `gcc --version` (should be GCC 9.4.0)
2) CMAKE (>3.18): in e.g. Downloads
2.1) `wget https://github.com/Kitware/CMake/releases/download/v3.26.0-rc4/cmake-3.26.0-rc4.tar.gz`
2.2) `sudo apt-get install libssl-dev` (cmake requires libssl)
2.3) extract and navigate to cmake directory
2.4) `./bootsrap`
2.5) `make -j8`
2.6) `sudo make install`
2.7) Check cmake version: `cmake --version` (should be 3.26)
3) CUDA: Do not use the default apt-get install cuda-nvidia-toolkit! This would be CUDA 10 in Ubuntu 20.04, which is incompatible.
3.1) Find specific CUDA versions here: https://developer.nvidia.com/cuda-toolkit-archive (will use 11.8.0 now)
3.2) Follow the instructions, e.g.:
```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda-repo-ubuntu2004-11-8-local_11.8.0-520.61.05-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-11-8-local_11.8.0-520.61.05-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2004-11-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda
```
3.3) If this installs a newer version e.g. CUDA 12, instead replace the final line with e.g.
```
sudo apt-get -y install cuda-11-8
```
3.4) To load this CUDA version, set env variables in your .nekrs_<>_profile (see above) by adding the following lines:
```
export PATH=$PATH:/usr/local/cuda-11.8/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-11.8/lib64
```
3.5) This CUDA version should be loaded when this .nekrs_<>_profile is sourced provided no other CUDA versions are added to the path and library path.
4) OpenMPI:
4.1) `sudo apt install libopenmpi-dev`
4.2) Check OpenMPI version: `mpirun --version` (default v4.0.3 in Ubuntu 20.04.5 should work, other versions may work)
4.3) Check mpi wrapper points to the correct gcc verison: `mpicc --version` should output the same version number as `gcc --version`, i.e. 9.4.0



Note: NekRS seems to have issues with using newer compilers etc., particularly with Ubuntu 22.04. Hopefully this will be updated in the near future.

Full CUDA installation instructions can be found here: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html
