# fastai

These are a set of scripts to help with the Fast.ai DL [course](http://course.fast.ai/)

### Instructions

The main instructions for setting up AWS for the course are [here](http://course.fast.ai/lessons/aws.html). The
course have you setup a GPU base AWS instance that rates at $0.90/hr. The scripts in this project allows
setting up an additional t2-micro instance that helps when doing non-DL workloads, like mungings.

#### Requirements

The rest of these instructions assumes that you have AWS credentials and installed the AWS cli. See [video](http://course.fast.ai/lessons/aws.html).

#### Initial setup

This project assumes that you have a copy of the Fast.ai [courses project](https://github.com/fastai/courses). To
get that code, run `make init`.

#### Create necessary images

The current scripts only generate the GPU based images.

Run `make setup` to execute the Fast.ai provided scripts to setup the AWS instance. Verify in [AWS console](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Instances:sort=instanceId) that
the instance was successfully created.

Creating the `t2-micro` instance is more of a manual process. This can still be easily done by running
the Fast.ai provided scripts. The goal is 2 instances that can share the same Volume, on free, the other expensive. Follow these steps:

1. Edit `courses/setup/setup_t2.sh` to create a `t2-micro` instance rather than a `t2.xlarge`.
2. Run `courses/setup/setup_t2.sh`
3. Verify that the instance was created in AWS console
4. Change the name of the new instance to be different than the gpu one. (i.e call it `fast-ai-munging-machine`)
5. Stop the instance if it is running
6. Go to the [Volumes](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Volumes:sort=desc:createTime) section in AWS Console and `Detach` and `Delete` the volume that was created for the `t2-micro` image. HINT: Most likely the one with the most recent date.
7. `Detach` the volume assigned to the `p2-xlarge` instance and `Attach` it to the `t2-micro`. Make sure that you set the `Device` to `/dev/sda1`. Note that for all this to work, both instances need to be stopped. (TODO: Automate all this!)

NOTE: Moving the volume to the correct instance is **manual**.

#### Start/Stoping an instance

Use `make start` and `make stop` to control the state of the instance. The first time any of this targets are
run, `make` will fail if it does not know what instance is currently used. This is a one time setup by setting the variable `INAME` to the `Name` or part of the `Name` of the instance. If using a partial name, make sure it uniquely identifies the instance. For example:

```
make start INAME=munging
```

This is cached and not needed for other commands. To clear things, run `make clean`.

#### Connection to the instance

Run `make connect` to ssh into the current instance.

#### Opening the Jupyter notebook

Run `make nb` and the Chrome will open the right URL. Note that this command assumes OSX.


### Resources
* AWS API - http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html
