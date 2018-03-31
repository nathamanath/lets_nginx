IMAGE_NAME = nathamanath/lets_nginx
REGISTRY_URL = registry.oneplaceapp.com
VERSION = $(shell cat version.txt)

build:
	@echo Build Docker images
	docker build -t $(IMAGE_NAME) .
	docker tag $(IMAGE_NAME) $(REGISTRY_URL)/$(IMAGE_NAME):latest
	docker tag $(IMAGE_NAME) $(REGISTRY_URL)/$(IMAGE_NAME):$(VERSION)

push:
	@echo Pushing to Docker registry
	docker push $(REGISTRY_URL)/$(IMAGE_NAME):latest
	docker push $(REGISTRY_URL)/$(IMAGE_NAME):$(VERSION)

release: build push
