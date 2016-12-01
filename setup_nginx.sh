# nginx config
echo "user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
	worker_connections 768;
	# multi_accept on;
}

http {

	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	# server_tokens off;

	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

  log_format nginx '$remote_addr - $remote_user [$time_local] '
                   '\"$request\" $status $body_bytes_sent $request_time '
                   '\"$http_referer\" \"$http_user_agent\"';

	##
	# Gzip Settings
	##

	gzip on;
	gzip_disable "msie6";

	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6;
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1;
	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}
" | sudo tee /etc/nginx/nginx.conf >/dev/null

# Server config
echo "server {
    listen 80 default_server;
    server_name _;

    access_log logs/host.access.log nginx;

    location / {
            add_header Content-Type text/plain;
            return 200 'lawng';
    }

    location /basic_status {
            stub_status on;

            access_log off;
            allow 127.0.0.1;
            deny all;
    }

}" | sudo tee /etc/nginx/sites-available/default >/dev/null

# Integrate nginx with datadog agent
echo "init_config:

instances:
  - nginx_status_url: http://localhost/basic_status
      tags:
        - instance: foo
" | sudo tee /etc/dd-agent/conf.d/nginx.yaml

# Make directory for access logs
sudo mkdir -p /usr/share/nginx/logs
