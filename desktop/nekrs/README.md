Build process (this assumes prerequisites are met e.g. cmake, CUDA, GNU compilers, MPI):

1) cd to ~/NekRS (create if it doesn't exist)
2) make a directory for the NekRS version, e.g. 22.0, public-nekrs etc
3) Clone NekRS source within that directory
4) Rename source directory to "build"
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
