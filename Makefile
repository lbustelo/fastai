.PHONY: help connect nb init setup
.DEFAULT_GOAL := help

include .config
include .env

help:
	#source:http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: courses
init: ## Setup machine to start the courese

setup: init ~/.ssh/aws-key-fast-ai.pem
setup: ## Run initial setup scripts

~/.ssh/aws-key-fast-ai.pem: ## Using
	 ./courses/setup/setup_p2.sh

courses:
	@git clone git@github.com:fastai/courses.git

connect: ## SSH to the AMI
	ssh -i ~/.ssh/aws-key-fast-ai.pem ubuntu@$(AMI_URL)

nb: ## Open the notebook
	@open -a "Google Chrome" "http://$(AMI_URL):$(NB_PORT)"
	@echo 'Password is dl_course'
