Build process:

1)  cd to $MY_RDS/NekRS/DAWN
2)  make a directory for the NekRS version (23.0)
3)  Clone NekRS source from github (https://github.com/Nek5000/nekRS) within that directory
4)  Rename source directory to "build"
5)  cd source
6)  Run `git tag` to list all tags, then `git checkout <branch-name>` (will get detached HEAD) for the v23 branch
7)  cd ..
8)  Make directory "setup" and move buildNek.sh script (in this repo) there
9)  Adjust buildNek.sh script to suit the installation (update dirname and dir)
10) Copy .nekrs_<version>_profile to ~ from this repo (note it will be hidden due to .), point to it in setup/buildNek.sh
11) from ~/NekRS/<version>, run ./setup/buildNek.sh, which will source the profile

To make the extra NekRS tools, cd to $MY_RDS/NekRS and run

`
git clone https://github.com/Nek5000/Nek5000.git
cd Nek5000/tools
./maketools all
`
