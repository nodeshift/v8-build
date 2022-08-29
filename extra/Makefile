MACHINE_ARCH = $(shell uname -m)

ifndef DOCKER_TARGET_LINK
  DOCKER_TARGET_LINK=
endif

ifndef NPROC
  NPROC=$(shell nproc)
endif

ifndef NAME
  $(error NAME is not set)
endif

IMG = $(DOCKER_TARGET_LINK)rt-nodejs-build-base-img-$(MACHINE_ARCH)

pull_base_image:
	docker pull $(IMG)

run: pull_base_image
	docker run -e "NPROC=$(NPROC)" $(IMG) bash -c "wget -O - https://raw.githubusercontent.com/nodeshift/v8-build/main/extra/$(NAME).sh | bash"
	docker system prune -f

.PHONY: pull_base_image run
