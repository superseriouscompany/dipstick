# dipstick

A nodejs app to test operational configurations.

## Running

    $ npm run dev

## Setup load balancers

    $ packer build -var 'aws_access_key=AKIAJQUENXU3RKGIAVQA' -var 'aws_secret_key=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' nginx.json

### AWS

1. Create three instances in AWS
1. Create ELB in AWS
1. Attach instances to ELB
1. Change security group of ELB to open http 80
1. Change security group of one instance to open http 80
1. Route DNS to load balancer
1. Route DNS to single instance.
