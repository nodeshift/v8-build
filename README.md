# Disclaimer
[V8](https://v8.dev/) is a community supported project. Our team at Red Hat maintains currency of the latest V8 releases to be used by Node.js on select PowerPC and S390x platforms. A list of platforms as well as their build toolchain supported by the Node.js can be found here:
https://github.com/nodejs/node/blob/master/BUILDING.md

We do not provide official support on V8 if it is used outside the realm of Node.js. V8 is built and tested
using the minimum compiler versions currently supported by Node.js (current versions are detailed in the above link). We do not officially support any other compiler versions or toolchain.

If you need to report a V8 related issue specific to PowerPC or S390x platforms please open a case using the Red Hat Customer Portal https://access.redhat.com/support/cases/

# Building and testing V8 using Docker
Docker images are used for building and testing V8 for ppc64le and s390x running Linux.

We have 2 types of images. The `base` image is used for development purposes. The `test` image, which is built on top of the base image, is used for automatic build and test of V8 commits on Jenkins.

You can run the following to create a base image and use it for development purposes:
```
make DOCKER_TARGET_LINK=your_docker_repo base-img
```

Run this to create all the images which also includes testing images used by Jenkins:
```
make DOCKER_TARGET_LINK=your_docker_repo build-all-images
```

# Manually building V8 on ppc64le and s390x running Linux
1- Build `ninja`

Note: `ninja-build` could also be available as a package under some Linux distributions in which
case you may not need to build it from source.

If needed, it can built from source using the following steps:
```
git clone https://github.com/ninja-build/ninja.git -b v1.8.2
cd ninja && ./configure.py --bootstrap
```  

2- Install pre-reqs and dependencies

Pre-reqs include the following:
- Compiler and build toolchain
- Third party libraries
- Python libraries
- Google GN
- Google depot_tools
Full list of dependencies and instructions on installing them can be found under `Dockerfile.base`.

Note: Our Dockerfile is based on Ubuntu. An equivalent list of dependencies for RHEL includes the following:
```
yum group install "Development Tools"
yum install -y python3 \
    curl \
    pkg-config \
    nss-devel \
    cups-libs \
    git \
    vim \
    glib2-devel \
    pango-devel \
    libpkgconf \
    gnome-keyring \
    glibc-static \
    libstdc++-static \
    atk-devel \
    gtk3-devel \
    wget
```
Python may also need to be symlinked with `ln -s /usr/bin/python3 /usr/bin/python`.

3- Set required PATH and environment variables:
Include `depot_tools` in your path and set the following env variable:
```py
export VPYTHON_BYPASS="manually managed python not supported by chrome operations"
```

4- Clone V8 by running `fetch v8` then change directory by `cd v8`.

5- Locate the `release.gn` file for your architecture under the `bin` folder in this repository and copy it to the `out` folder of `v8`, rename it to `args.gn`.

Current args list includes flags used by our build bots, you may need to modify the list based on your needs. Documentation for GN as well as V8 flags can be found here:
https://gn.googlesource.com/gn/+/master/docs/reference.md
https://github.com/v8/v8/blob/main/src/flags/flag-definitions.h

6- Generate build files by running: `gn gen out` (Use platform specific `gn` binary built in step 2)

7- Initiate build by running: `ninja -C out` (Use platform specific `ninja` binary built in step 1)

Once finished `d8` should be available under `v8/out`.
