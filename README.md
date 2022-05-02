# Disclaimer
[V8](https://v8.dev/) is a community supported project. Our team at Red Hat maintains currency of the latest V8 releases to be used by Node.js on Linux on IBM Power (ppcle64), AIX and Linux on IBM zSystems / LinuxONE (s390x). The official list of Node.js platforms, along with their respective toolchains, can be found at:
https://github.com/nodejs/node/blob/master/BUILDING.md

We do not provide official support on V8 if it is used outside the realm of Node.js. V8 is built and tested using the minimum compiler versions currently supported by Node.js (current versions are detailed in the above link). We do not support any other compiler versions or toolchain.

If you need to report a V8 related issue specific to PowerPC or S390x platforms please open a case using the Red Hat Customer Portal https://access.redhat.com/support/cases/

# Building and testing V8 using Docker
Docker images are used for building and testing V8 for ppc64le and s390x running Linux.

We have 2 types of images. The `base` image provides the base configuration with the necessary development toolchains installed to build V8. The `test` image, built upon the base, is used to clone, build and test V8 commits by the Jenkins CI/CD pipeline.

You can run the following to create a base image and use it for development purposes:
```
make DOCKER_TARGET_LINK=your_docker_repo base-img
```

Run this to create all the images which also includes testing images used by Jenkins:
```
make DOCKER_TARGET_LINK=your_docker_repo build-all-images
```