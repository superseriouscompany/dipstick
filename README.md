# dipstick

A nodejs app to test operational configurations.

## Running

    $ npm run dev

## Generate nginx images

    $ packer build nginx.json

### Set up AWS, GCP and Digital Ocean load balancers

1. Save google cloud platform credentials as gcp.json
1. Make aws keys available at TF_VAR_access_key and TF_VAR_secret_key

    $ terraform apply

### DIGITAL OCEAN

1. Create three instances from the new image with private ips enabled
1. Create a HAProxy

Note: ssh to aws with `ubuntu` username and digitalocean with `root`

## Monitoring

### Datadog AWS

1. Sign up for datadog
1. Install mac osx agent
1. Follow aws integration steps http://docs.datadoghq.com/integrations/aws/
1. Enable detailed monitoring http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch-new.html
1. Star default AWS EC2, ELB and overview graphs
1. Create dashboard
1. Create graph with CPU utilization per instance
1. Create graph with pct memory available per instance
1. Add DD_API_KEY to environment variables
1. Install agent on hosts
1. Add ELB monitor for 2xx, 4xx, 5xx, request count
1. Add ELB monitor for latency
1. Add nginx integration to agent
1. Add nginx RPS per host to datadog

### Datadog GCP

1. Add gcp integration
1.
