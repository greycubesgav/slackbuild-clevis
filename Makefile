# DOCKER FROM Image Settings
DOCKER_USER=greycubesgav
DOCKER_BASE_IMAGE_NAME=slackware-docker-base
DOCKER_BASE_IMAGE_TAG=aclemons
DOCKER_BASE_IMAGE_VERSION=15.0
# Default Source Code Version
SOURCE_VERSION=20
SOURCE_BUILD_TAG=_$(DOCKER_BASE_IMAGE_VERSION)_GG
# DOCKER TAG Image Settings
DOCKER_TARGET_IMAGE_NAME=slackbuild-clevis
DOCKER_PLATFORM=linux/amd64
# Add NOCACHE='--no-cache' to force a rebuild
NOCACHE=
# Set the build version to the current date
BUILD=$(shell date +%Y%m%d)
# Make sure we are running bash, not 'dash' under github actions
SHELL := /usr/bin/env bash

# By default, build package versions and variants
default: docker-artifact-build-current docker-artifact-build-15.0

# Build the package against slackware-current (libcrypto.so.3) and tag the package appropriately
docker-image-build-current:
	$(MAKE) docker-image-build DOCKER_BASE_IMAGE_VERSION='current' BUILD='$(BUILD)'

# Build the package against slackware-v15 (libcrypto.so.1.1) and tag the package appropriately
docker-image-build-15.0:
	$(MAKE) docker-image-build DOCKER_BASE_IMAGE_VERSION='15.0' BUILD='$(BUILD)'

# Build the package using the variables set in the Makefile
docker-image-build:
	$(eval DOCKER_FULL_BASE_IMAGE_NAME=$(DOCKER_USER)/$(DOCKER_BASE_IMAGE_NAME):$(DOCKER_BASE_IMAGE_TAG)-$(DOCKER_BASE_IMAGE_VERSION))
	$(eval DOCKER_FULL_TARGET_IMAGE_NAME=$(DOCKER_USER)/$(DOCKER_TARGET_IMAGE_NAME):v$(SOURCE_VERSION)-$(DOCKER_BASE_IMAGE_VERSION))
	@echo "Building $(DOCKER_FULL_TARGET_IMAGE_NAME) against $(DOCKER_FULL_BASE_IMAGE_NAME)"
	docker build --platform $(DOCKER_PLATFORM) --file Dockerfile \
		$(NOCACHE) \
		--build-arg DOCKER_FULL_BASE_IMAGE_NAME="$(DOCKER_FULL_BASE_IMAGE_NAME)" \
		--build-arg TAG='_$(DOCKER_BASE_IMAGE_VERSION)_GG' \
		--build-arg VERSION=$(SOURCE_VERSION) \
		--build-arg BUILD=$(BUILD) \
		--tag $(DOCKER_FULL_TARGET_IMAGE_NAME) .

docker-image-run-current:
	$(MAKE) docker-image-run DOCKER_BASE_IMAGE_VERSION='current'

docker-image-run-15.0:
	$(MAKE) docker-image-run  DOCKER_BASE_IMAGE_VERSION='15.0'


#	docker build --platform $(DOCKER_PLATFORM) --file Dockerfile --tag $(DOCKER_USER)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) .
docker-image-run:
	$(eval DOCKER_FULL_BASE_IMAGE_NAME=$(DOCKER_USER)/$(DOCKER_BASE_IMAGE_NAME):$(DOCKER_BASE_IMAGE_TAG)-$(DOCKER_BASE_IMAGE_VERSION))
	$(eval DOCKER_FULL_TARGET_IMAGE_NAME=$(DOCKER_USER)/$(DOCKER_TARGET_IMAGE_NAME):v$(SOURCE_VERSION)-$(DOCKER_BASE_IMAGE_VERSION))
	@echo "Running $(DOCKER_FULL_TARGET_IMAGE_NAME)"
	docker run --platform $(DOCKER_PLATFORM) --rm -it \
		$(DOCKER_FULL_TARGET_IMAGE_NAME)

# -------------------------------------------------------------------------------------------------------
#  Package Extraction
# -------------------------------------------------------------------------------------------------------

docker-artifact-build-current:
	$(MAKE) docker-artifact-build DOCKER_BASE_IMAGE_VERSION='current' BUILD='$(BUILD)'

docker-artifact-build-15.0:
	$(MAKE) docker-artifact-build DOCKER_BASE_IMAGE_VERSION='15.0' BUILD='$(BUILD)'

docker-artifact-build:
	$(eval DOCKER_FULL_BASE_IMAGE_NAME=$(DOCKER_USER)/$(DOCKER_BASE_IMAGE_NAME):$(DOCKER_BASE_IMAGE_TAG)-$(DOCKER_BASE_IMAGE_VERSION))
	$(eval DOCKER_FULL_TARGET_IMAGE_NAME=$(DOCKER_USER)/$(DOCKER_TARGET_IMAGE_NAME):v$(SOURCE_VERSION)-$(DOCKER_BASE_IMAGE_VERSION))
	@echo "Extracting artifact from $(DOCKER_FULL_TARGET_IMAGE_NAME) to ./pkgs/"
	DOCKER_BUILDKIT=1 docker build --platform $(DOCKER_PLATFORM) --file Dockerfile \
		$(NOCACHE) \
		--build-arg DOCKER_FULL_BASE_IMAGE_NAME="$(DOCKER_FULL_BASE_IMAGE_NAME)" \
		--build-arg TAG='_$(DOCKER_BASE_IMAGE_VERSION)_GG' \
		--build-arg VERSION=$(SOURCE_VERSION) \
		--build-arg BUILD=$(BUILD) \
		--target artifact --output type=local,dest=./pkgs/ .
# Create Unraid version copies for simpler installs
	if ls ./pkgs/*_current_*.t?z 1> /dev/null 2>&1; then \
		for f in ./pkgs/*_current_*.t?z; do cp "$$f" "$${f/_current_/_unraid-v7.x.x_}"; done \
	fi
	if ls ./pkgs/*_15.0_*.t?z 1> /dev/null 2>&1; then \
		for f in ./pkgs/*_15.0_*.t?z; do cp "$$f" "$${f/_15.0_/_unraid-v6.x.x_}"; done \
	fi

