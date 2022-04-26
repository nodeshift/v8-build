#!/bin/bash

if [[ -z "$NPROC" ]] ; then
  NPROC=$(nproc)
fi

# set path to gn depending on architecture, install any dependencies
MACHINE_ARCH=
if [ $(uname -m) == "s390x" ] ;
then
    MACHINE_ARCH="s390x"
elif [ $(uname -m) == "ppc64le" ] ;
then
    MACHINE_ARCH="ppc64"
else
    echo "We only build on ppc64le and s390x, exiting!"
    exit
fi

 # print the compiler version
 g++ --version

if [[ ! -f /home/$MACHINE_ARCH/$MODE.gn ]] ; then
  # Build and test Abseil, then exit.
  if [[ $MODE == "abseil" ]];
  then
    git clone https://github.com/abseil/abseil-cpp.git && cd abseil-cpp
    git checkout master
    mkdir build && cd build
    cmake -DABSL_BUILD_TESTING=ON -DBUILD_TESTING=ON -DABSL_USE_GOOGLETEST_HEAD=ON -DCMAKE_CXX_STANDARD=11 ..
    MAKEFLAGS="-j$NPROC" cmake --build . --target all
    ctest -j$NPROC
    exit
  else
    echo "ERROR: MODE $MODE unknown!!!"
    exit
  fi
fi

# Build and test V8.
echo "===================================="
echo "Architecture is:" $MACHINE_ARCH
echo "Mode is:" $MODE
echo "Parallel Build/Test (-j):" $NPROC
echo "===================================="

# fetch latest v8
fetch v8
cd v8

# Iterate through passed features
# They need to be passed to `make`, exmaple: `make NPROC=4 test-debug-master features="enable-simd"`
# patches need to go as `diff` files under the `build\patches` folder, exmaple: `patches/enable-simd.patch`
echo "===================================="
echo "Features:"
for arg in "$@"
do
  if [[ -f ../patches/"$arg".patch ]] ; then
    echo "Running patch for $arg";
    patch -p1 < ../patches/"$arg".patch;
  fi
done
echo "===================================="

git branch -at |\
  /bin/grep branch-heads |\
  /bin/grep -o '/[0-9.]*\.[0-9]*' |\
  sed s/^.// |\
  sort -nr > v8-branches.txt

V8_BETA_BRANCH=$(sed '1q;d' v8-branches.txt)
V8_STABLE_BRANCH=$(sed '2q;d' v8-branches.txt)

if [ "$V8_BRANCH" != "main" ]; then
  if [ "$V8_BRANCH" == "beta" ]; then
    V8_BRANCH=branch-heads/$V8_BETA_BRANCH
  elif [ "$V8_BRANCH" == "stable" ]; then
    V8_BRANCH=branch-heads/$V8_STABLE_BRANCH
  fi
fi

echo "===================================="
echo "Checkout branch $V8_BRANCH"
echo "===================================="

git checkout $V8_BRANCH
if [ "$V8_BRANCH" != "main" ]; then
    gclient sync
fi

# copy args required for gn, build
mkdir out/$MACHINE_ARCH
cp /home/$MACHINE_ARCH/$MODE.gn out/$MACHINE_ARCH/args.gn
gn gen /home/v8/out/$MACHINE_ARCH
ninja -C /home/v8/out/$MACHINE_ARCH -j $NPROC

# run tests
python3 tools/run-tests.py -j $NPROC --time --progress=dots --timeout=240 --no-presubmit \
                                --outdir=out/$MACHINE_ARCH --variants=exhaustive
