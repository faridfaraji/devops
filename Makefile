# Project configuration
PROJECT_NAME = lemay-project

ifeq ($(shell uname -p), arm)
DOCKER_PLATFORM = --platform linux/amd64
else
DOCKER_PLATFORM =
endif

default: help

help: # Display help
	@awk -F ':|##' \
		'/^[^\t].+?:.*?##/ {\
			printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF \
		}' $(MAKEFILE_LIST) | sort

build-docker: ## Build the docker images
	docker build $(DOCKER_PLATFORM) -t producer-app -f Dockerfile-producer .
	docker build $(DOCKER_PLATFORM) -t consumer-app -f Dockerfile-consumer .

tag-docker: ## Tag the docker images, change the project name accordingly
	docker tag producer-app gcr.io/$(PROJECT_NAME)/producer-app:latest
	docker tag consumer-app gcr.io/$(PROJECT_NAME)/consumer-app:latest

push-docker: ## push the images to registry, change the project name accordingly
	docker push gcr.io/$(PROJECT_NAME)/producer-app:latest
	docker push gcr.io/$(PROJECT_NAME)/consumer-app:latest

k8-cluster: ## deploy service to cluster
	kubectl apply -f deploy/zookeeper.yaml
	kubectl apply -f deploy/kafka.yaml
	kubectl apply -f deploy/elasticsearch.yaml
	kubectl apply -f deploy/neo4j.yaml
	kubectl apply -f deploy/producer_app.yaml
	kubectl apply -f deploy/consumer_app.yaml

.PHONY: default help start build-docker run-docker stop-docker test clean-code clean-docker code setup
