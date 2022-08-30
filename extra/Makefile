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
