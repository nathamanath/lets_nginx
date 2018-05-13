IMAGE_NAME = nathamanath/lets_nginx
VERSION = $(shell cat version.txt)

build:
	@echo Build Docker images
	docker build -t $(IMAGE_NAME) .
	docker tag $(IMAGE_NAME) $(IMAGE_NAME):latest
	docker tag $(IMAGE_NAME) $(IMAGE_NAME):$(VERSION)
