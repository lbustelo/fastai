.PHONY: help clean connect nb init setup start stop status ip name id dns info
.DEFAULT_GOAL := help

include .env

#source: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

clean: ## Cleans the project
	-@rm .aws-*

init: courses
init: ## Setup machine to start the courses

setup: init ~/.ssh/aws-key-fast-ai.pem
setup: ## Run initial setup scripts

~/.ssh/aws-key-fast-ai.pem: ## Using
	 ./courses/setup/setup_p2.sh

courses:
	@git clone git@github.com:fastai/courses.git

.aws-instance-name:
	@if [ "${INAME}" = "" ]; then \
		echo "Environment variable INAME not set"; \
		exit 1; \
	fi
	@echo '${INAME}' > $@

.aws-instance-id: .aws-instance-name
	@echo `instanceName=$$(cat .aws-instance-name); aws ec2 describe-instances --filters "Name=tag:Name,Values=*$$instanceName*" --query "Reservations[0].Instances[0].InstanceId"` > $@

.aws-instance-ip: .aws-instance-id
	@echo `instanceId=$$(cat .aws-instance-id); aws ec2 describe-instances --filters "Name=instance-id,Values=$$instanceId" --query "Reservations[0].Instances[0].PublicIpAddress"` > $@

.aws-instance-dns: .aws-instance-id
	@echo `instanceId=$$(cat .aws-instance-id); aws ec2 describe-instances --filters "Name=instance-id,Values=$$instanceId" --query "Reservations[0].Instances[0].PublicDnsName"` > $@

start: .aws-instance-id
start: ## Starts the instance
	@instanceId=$$(cat .aws-instance-id); aws ec2 start-instances --instance-ids $$instanceId && aws ec2 wait instance-running --instance-ids $$instanceId

stop: .aws-instance-id
stop: ## Stops the instance
	@instanceId=$$(cat .aws-instance-id); aws ec2 stop-instances --instance-ids $$instanceId

status: .aws-instance-id
status: ## Gets the status of the instance
	@instanceId=$$(cat .aws-instance-id); aws ec2 describe-instances --instance-ids $$instanceId --query "Reservations[0].Instances[0].State.Name"

id: .aws-instance-id
id: ## Gets the IP of the instance
	@instanceId=$$(cat .aws-instance-id); echo "ID is $$instanceId"

ip: .aws-instance-ip
ip: ## Gets the IP of the instance
	@instanceIp=$$(cat .aws-instance-ip); echo "IP is $$instanceIp"

name: .aws-instance-name
	@instanceName=$$(cat .aws-instance-name); echo "Name is $$instanceName"

dns: .aws-instance-dns
	@instanceDNS=$$(cat .aws-instance-dns); echo "DNS is $$instanceDNS"

info: id ip name dns
info: ## Displays the info for the current instance

connect: .aws-instance-ip
connect: ## SSH into the instance
	@instanceIp=$$(cat .aws-instance-ip); ssh -i ~/.ssh/aws-key-fast-ai.pem ubuntu@$$instanceIp

nb: .aws-instance-dns
nb: ## Open a browser to the notebook running in the instance
	@instanceDNS=$$(cat .aws-instance-dns); open -a "Google Chrome" "http://$$instanceDNS:$(NB_PORT)"
	@echo 'Password is dl_course'

run-nb: CMD=cd ~/courses/deeplearning1/nbs && jupyter notebook
run-nb: NAME=jup-nb
run-nb: ## Runs the jupyter notebook on the remote instance
	@echo "THIS DOES NOT WORK!"
	@exit 1
	@instanceIp=$$(cat .aws-instance-ip); ssh -n -f -i ~/.ssh/aws-key-fast-ai.pem ubuntu@$$instanceIp "bash -c '$(CMD)' > $(NAME).out 2> $(NAME).err < /dev/null &"
