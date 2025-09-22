# Build instructions

NekRS has the following system requirements:

- Linux, Mac OS X (Microsoft WSL and Windows is not supported)
- C++17/C99 compatible compiler
- GNU/Intel/NVHPC Fortran compiler
- MPI-3.1 or later
- CMake version 3.18 or later

The Cardinal (MOOSE) build also requires the following:
- Python 3, pip and venv
- flex
- bison
- gawk
- libtirpc-dev
- CMake version 3.26.0 (more recent than required by NekRS)

These must be installed before running the build script.
- `build_NekRS_CPU.sh` installs a CPU-only version of NekRS
- `build_NekRS_CUDA.sh` installs a version of NekRS compatible with Nvidia GPUs. However the user will need to install the required CUDA prerequisites.

## Ubuntu 22.04

Ubuntu 22.04 comes with GCC version 11.4.0 (if this is missing, install it with `sudo apt install build-essential). To install OpenMPI 4.1.2, gfortran 11.4.0, git and other requirements:

```
sudo apt update
sudo apt upgrade -y
sudo apt install gfortran -y
sudo apt install openmpi-bin libopenmpi-dev -y
sudo apt install git -y
sudo apt install flex bison gawk libtirpc-dev -y
sudo apt install python3-dev python3-pip python3-venv -y
```

To install a version of CMake that can be used to build Cardinal (3.28.3), use the Kitware APT repository:
```
test -f /usr/share/doc/kitware-archive-keyring/copyright ||
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null
sudo apt-get update
test -f /usr/share/doc/kitware-archive-keyring/copyright ||
sudo rm /usr/share/keyrings/kitware-archive-keyring.gpg
sudo apt-get install kitware-archive-keyring
sudo apt install cmake=3.28.3-0kitware1ubuntu22.04.1
```

## Ubuntu 24.04

Ubuntu 24.04 comes with GCC and gfortran version 13.3.0, however NekRS v23 is not compatible with this version of the GNU compilers. To install cmake 3.28.3, OpenMPI 4.1.6, git, GNU compilers version 12.4 and other requirements:

```
sudo apt update
sudo apt upgrade -y
sudo apt install cmake -y
sudo apt install openmpi-bin libopenmpi-dev -y
sudo apt install gcc-12 g++12 gfortran-12 -y
sudo apt install git -y
sudo apt install flex bison gawk libtirpc-dev -y
sudo apt install python3-dev python3-pip python3-venv -y
```

In order to use these older compilers, add the following lines at the end of the section generating the Cardinal profile:

```
echo "export OMPI_CXX=g++-12" >> $HOME/.$PROFILE_NAME
echo "export OMPI_FORT=gfortran-12" >> $HOME/.$PROFILE_NAME
```