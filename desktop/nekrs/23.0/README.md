# Build instructions

NekRS has the following system requirements:

- Linux, Mac OS X (Microsoft WSL and Windows is not supported)
- C++17/C99 compatible compiler
- GNU/Intel/NVHPC Fortran compiler
- MPI-3.1 or later
- CMake version 3.18 or later

These must be installed before running the build script.
- `build_NekRS_CPU.sh` installs a CPU-only version of NekRS
- `build_NekRS_CUDA.sh` installs a version of NekRS compatible with Nvidia GPUs. However the user will need to install the required CUDA prerequisites.

## Ubuntu 22.04

Ubuntu 22.04 comes with GCC version 11.4.0 (if this is missing, install it with `sudo apt install build-essential). To install cmake 3.22.1, OpenMPI 4.1.2, gfortran 11.4.0 and git:

```
sudo apt update
sudo apt upgrade -y
sudo apt install gfortran -y
sudo apt install cmake -y
sudo apt install openmpi-bin libopenmpi-dev -y
sudo apt install git -y
```

## Ubuntu 24.04

Ubuntu 24.04 comes with GCC and gfortran version 13.3.0, however NekRS v23 is not compatible with this version of the GNU compilers. To install cmake 3.28.3, OpenMPI 4.1.6, git and GNU compilers version 12.4:

```
sudo apt update
sudo apt upgrade -y
sudo apt install cmake -y
sudo apt install openmpi-bin libopenmpi-dev -y
sudo apt install gcc-12 g++12 gfortran-12 -y
sudo apt install git -y
```

In order to use these older compilers for the NekRS build, add the following lines at the end of the section generating the NekRS profile:

```
echo "export OMPI_CXX=g++-12" >> $HOME/.$PROFILE_NAME
echo "export OMPI_FORT=gfortran-12" >> $HOME/.$PROFILE_NAME
```