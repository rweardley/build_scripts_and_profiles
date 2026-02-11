# Building NekRS v26 on Ubuntu 24.04 in WSL

Instructions for building NekRS v26 on Ubuntu 24.04 in WSL, shared by Ben Li in the NE CFD slack.

1. Apply a patch: `git apply wsl_v26_ubuntu_2404.patch`
2. Dependencies: `libopenmpi-dev`, `nvidia-cuda-toolkit`, and maybe other packages he already had installed for OpenFOAM, plus [packages for the standard WSL CUDA set up](https://docs.nvidia.com/cuda/wsl-user-guide/index.html#getting-started-with-cuda-on-wsl-2)
3. Build with `CC=mpicc CXX=mpic++ FC=mpif77 ./build.sh -DCMAKE_INSTALL_PREFIX=$HOME/.local/nekrs -DENABLE_HYPRE_GPU=off -DCMAKE_BUILD_TYPE=Debug`
  - Note it reportedly fails for normul builds and only debug builds work
4. Build and run a case, e.g. `mpirun -np 1 --mca osc pt2pt nekrs --setup`

## Some other comments

Yu-Hsiang Lan:
> @Ben Li, Can you try undo the occa changes and disable DPCPP manually `-DOCCA_ENABLE_DPCPP=no` and change flags via `OCCA_CXXFLAGS` or something in `CMakeLists.txt`? Also, it's probably good to add WSL into our doc. 
> https://github.com/Nek5000/nekRS_doc
> https://github.com/Nek5000/nekRS_doc/blob/4d477d8e8f464c428ab92e21a74de8acc392b759/source/quickstart.rst?plain=1#L22-L49
> For `--mca osc pt2pt`, it seems that you are using openMPI. and it might support these `export OMPI_MCA_osc=pt2pt` so you can put it in env var.

Ben Li: 
> 1. `-DOCCA_ENABLE_DPCPP=no` works great, will omit the dpcpp patch. Thanks!
> 2. Regarding `OCCA_CXXFLAGS` those seem to be the flags for case compile, and adding `-Wno-dangling-reference` there didn't work (I'll DM you the patch I tried and the output). I couldn't find a way to cleanly set flags on a cmake subdir without setting them globally. Maybe we can just add `-DCMAKE_CXX_FLAGS="-Wno-dangling-reference"` to the `./build.sh` instructions. Will omit the cmake patch too.
> 3. OK, will add these instructions to the docs
> 4. Sounds good, that can go in the docs too
