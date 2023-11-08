#!/bin/bash

#  Copyright 2022 Red Hat, Inc, and individual contributors.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

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

if [[ ! -f /home/$MACHINE_ARCH/$MODE.gn ]] ; then
  echo "ERROR: MODE $MODE  unknown!!!"
  exit
fi

# print the compiler version
g++ --version

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
# They need to be passed to `make`, example: `make NPROC=4 test-debug-master features="enable-simd"`
# patches need to go as `diff` files under the `build\patches` folder, example: `patches/enable-simd.patch`
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

# checkout a branch or a commit hash
CHECKOUT=$V8_BRANCH
if [[ -n "$V8_HASH" ]] ; then
  CHECKOUT=$V8_HASH
elif [ "$V8_BRANCH" != "main" ]; then
  if [ "$V8_BRANCH" == "beta" ]; then
    CHECKOUT=branch-heads/$V8_BETA_BRANCH
  elif [ "$V8_BRANCH" == "stable" ]; then
    CHECKOUT=branch-heads/$V8_STABLE_BRANCH
  fi
fi

echo "===================================="
echo "Checkout $CHECKOUT"
echo "===================================="

git checkout $CHECKOUT
if [ "$CHECKOUT" != "main" ]; then
    gclient sync
fi

# cherry-pick a CL if needed
if [[ -n "$CHERRY_PICK" ]] ; then
  REF=refs/changes/$CHERRY_PICK
  echo "===================================="
  echo "Cherry picking $REF"
  echo "===================================="
  git fetch https://chromium.googlesource.com/v8/v8 $REF && git cherry-pick FETCH_HEAD
fi

# copy args required for gn, build
mkdir -p out/$MACHINE_ARCH
cp /home/$MACHINE_ARCH/$MODE.gn out/$MACHINE_ARCH/args.gn
gn gen /home/v8/out/$MACHINE_ARCH
ninja -C /home/v8/out/$MACHINE_ARCH -j $NPROC

# run tests
python tools/run-tests.py -j $NPROC --time --progress=dots --timeout=240 --no-presubmit \
                                --outdir=out/$MACHINE_ARCH --variants=exhaustive
