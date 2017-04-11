.PHONY: help clean connect nb init setup start stop status ip
.DEFAULT_GOAL := help

include .config
include .env

help:
	#source:http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

clean: ## Cleans the project
	-@rm .aws-*

init: courses
init: ## Setup machine to start the courese

setup: init ~/.ssh/aws-key-fast-ai.pem
setup: ## Run initial setup scripts

~/.ssh/aws-key-fast-ai.pem: ## Using
	 ./courses/setup/setup_p2.sh

courses:
	@git clone git@github.com:fastai/courses.git

.aws-instance-id:
	@echo `aws ec2 describe-instances --filters "Name=instance-state-name,Values=stopped,Name=instance-type,Values=p2.xlarge" --query "Reservations[0].Instances[0].InstanceId"` > $@

.aws-instance-ip: .aws-instance-id
	@echo `instanceId=$$(cat .aws-instance-id); aws ec2 describe-instances --filters "Name=instance-id,Values=$$instanceId" --query "Reservations[0].Instances[0].PublicIpAddress"` > $@

start: .aws-instance-id
start: ## Starts the instance
	@instanceId=$$(cat .aws-instance-id); aws ec2 start-instances --instance-ids $$instanceId && aws ec2 wait instance-running --instance-ids $$instanceId

stop: .aws-instance-id
stop: ## Stops the instance
	@instanceId=$$(cat .aws-instance-id); aws ec2 stop-instances --instance-ids $$instanceId

status: .aws-instance-id
status: ## Gets the status of the instance
	@instanceId=$$(cat .aws-instance-id); aws ec2 describe-instances --instance-ids $$instanceId --query "Reservations[0].Instances[0].State.Name"

ip: .aws-instance-ip
ip: ## Gets the IP of the instance
	@instanceIp=$$(cat .aws-instance-ip); echo "IP is $$instanceIp"

connect: .aws-instance-ip
connect: ## SSH into the instance
	@instanceIp=$$(cat .aws-instance-ip); ssh -i ~/.ssh/aws-key-fast-ai.pem ubuntu@$$instanceIp

nb: ## Open a browser to the notebook running in the instance
	@open -a "Google Chrome" "http://$(AMI_URL):$(NB_PORT)"
	@echo 'Password is dl_course'
