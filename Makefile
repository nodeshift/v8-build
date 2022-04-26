
MACHINE_ARCH = $(shell uname -m)

DOCKER_NO_CACHE=--no-cache
DOCKER_BUILD=docker build $(DOCKER_NO_CACHE)

ifndef DOCKER_TARGET_LINK
  DOCKER_TARGET_LINK=
endif

ifndef NPROC
  NPROC=$(shell nproc)
endif

BASE_IMAGE = base-img

TESTS = test-debug-stable     \
        test-release-stable   \
        test-debug-beta       \
        test-release-beta     \
        test-debug-main     \
        test-release-main   \
        test-ptrcompr-main  \
        test-jsargreverse-main \
	test-abseil-master

TEST_IMAGES = $(foreach test, $(TESTS), $(test)-img)
TEST_DOCKERFILE = $(foreach test, $(TESTS), Dockerfile.$(test))

ALL_IMAGES = base-img $(TEST_IMAGES)
PUSH_IMAGES = $(foreach image, $(ALL_IMAGES), $(image)-push)

$(BASE_IMAGE): Dockerfile.base
	$(DOCKER_BUILD) -t $(DOCKER_TARGET_LINK)rt-nodejs-build-$@-$(MACHINE_ARCH) -f $< .

$(TEST_IMAGES): %-img: Dockerfile.% base-img
	$(DOCKER_BUILD) -t $(DOCKER_TARGET_LINK)rt-nodejs-build-$@-$(MACHINE_ARCH) -f $< .

$(TEST_DOCKERFILE): Dockerfile.%: Dockerfile.test-template
	DOCKER_TARGET_LINK=$(DOCKER_TARGET_LINK) bash generate_dockerfile.sh $@

$(TESTS): %:
	docker pull $(DOCKER_TARGET_LINK)rt-nodejs-build-$@-img-$(MACHINE_ARCH)
	docker run -e "NPROC=$(NPROC)" $(DOCKER_TARGET_LINK)rt-nodejs-build-$@-img-$(MACHINE_ARCH) $(features)
	docker system prune -f

define PUSH
	docker push $(DOCKER_TARGET_LINK)rt-nodejs-build-$(1)-$(MACHINE_ARCH);
endef

push-all-images:
	$(call PUSH,base-img)
	$(foreach image, $(TEST_IMAGES), $(call PUSH,$(image)))

build-all-images: $(BASE_IMAGE) $(TEST_IMAGES)

run-all-tests: $(TESTS)

clean:
	rm -f $(TEST_DOCKERFILE)

.PHONY: $(ALL_IMAGES)
.PHONY: $(TESTS)
.PHONY: push-all-images build-all-images run-all-tests clean



