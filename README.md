# dipstick

A nodejs app to test operational configurations.

## Running

    $ npm run dev

## Setup load balancers

    $ packer build -var 'aws_access_key=AKIAJQUENXU3RKGIAVQA' -var 'aws_secret_key=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' nginx.json

### AWS

1. Create three instances in AWS from the new image
1. Create ELB in AWS
1. Attach instances to ELB
1. Change security group of ELB to open http 80
1. Change security group of one instance to open http 80
1. Route DNS to load balancer
1. Route DNS to single instance.

### GCP

1. Create an instance group
1. Create three instances in the group from the new image
1. Create a load balancer
1. Attach the instance group to the load balancer
1. Open the http port on one of the instances
1. Route DNS to load balancer
1. Route DNS to single instance

### DIGITAL OCEAN

1. Create three instances from the new image with private ips enabled
1. Create a HAProxy

Note: ssh to aws with `ubuntu` username and digitalocean with `root`
