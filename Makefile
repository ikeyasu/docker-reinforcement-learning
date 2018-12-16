# Docker organization to pull the images from
ORG = ikeyasu

# Name of image
IMAGE = reinforcement-learning

# Docker TAG
TAG = latest

build:
	docker build \
		-t $(ORG)/$(IMAGE):$(TAG) \
		--build-arg IMAGE=$(ORG)/$(IMAGE):$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--cpu-period=1000000 --cpu-quota=3000000 --cpuset-cpus 0-2 \
		.

.PHONY: build
