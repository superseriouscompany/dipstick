# dipstick

A nodejs app to test operational configurations.

## Running

    $ npm run dev

## Generate packer image

    $ packer build ssc.json

### Set up AWS, GCP and Digital Ocean load balancers

1. Save google cloud platform credentials as gcp.json and create symbolic links to `terraform/` and `terraform/gcp`
1. Make aws keys available at TF_VAR_access_key and TF_VAR_secret_key

    $ (cd terraform && terraform apply)

Note: For digital ocean, you now need to take the ip addresses that were output and plug them into a HAProxy instance.

Note: ssh to aws/gcp with `ubuntu` username and digitalocean with `root`

### Running just one service (e.g. gcp)

    $ cd terraform/gcp
    $ terraform apply

remember that you have to `terraform destroy` separately in each folder you start shit up from.

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

## Prometheus

1. Download prometheus https://prometheus.io/download/

    $ tar -xzvf prometheus-1.4.1.darwin-amd64
    $ ./prometheus-1.4.1.darwin-amd64/prometheus -config.file=./prometheus.yml

Add new server IPs to prometheus.yml

## Grafana

CPU

1. `$ brew install grafana`
1. start prometheus
1. add prometheus datasource
1. add prometheus dashboard
1. import single instance json
1. stress test CPU with `yes > /dev/null`


MEMORY

1. `sudo apt-get install stress`
1. `watch free -m`
1. `stress -m 1`

Latency

1. follow installation instructions https://github.com/knyar/nginx-lua-prometheus
1. hook up prometheus.yml to the nginx config
1. average latency: rate(nginx_http_request_duration_seconds_sum[5m]) / rate(nginx_http_request_duration_seconds_count[5m])
1. p99 using quantiles
1. per endpoint hopefully using lua

RPS
1. ???

## ELK and metricsbeat

1. https://www.elastic.co/guide/en/beats/libbeat/5.0/elasticsearch-installation.html
1. https://www.elastic.co/guide/en/beats/libbeat/5.0/kibana-installation.html
1. `ssh -NfL 5601:127.0.0.1:5601 ubuntu@<ip>`
1. https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-installation.html
1. https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation.html
1. Change log paths in yml
