# Building and testing V8 using Docker
Docker images for building and testing V8 master code on ppc64le and s390x.

We have 2 types of images, the `base` images which are used for development and the `test` images which are built on top of the base images and are used to build and test V8 commits on Jenkins automatically.

To create v8 building environment inside docker:
```
make DOCKER_TARGET_LINK=your_docker_repo base-img
```

To create v8 testing docker images:
```
make DOCKER_TARGET_LINK=your_docker_repo build-all-images && make DOCKER_TARGET_LINK=your_docker_repo test-release-main
```

