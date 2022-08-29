#!/bin/bash

if [[ -z "$NPROC" ]] ; then
  NPROC=$(nproc)
fi

git clone https://github.com/abseil/abseil-cpp.git && cd abseil-cpp
git checkout master
mkdir build && cd build
cmake -DABSL_BUILD_TESTING=ON -DBUILD_TESTING=ON -DABSL_USE_GOOGLETEST_HEAD=ON ..
MAKEFLAGS="-j$NPROC" cmake --build . --target all
ctest -j$NPROC
