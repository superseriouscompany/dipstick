echo "server {
    listen 80 default_server;
    server_name _;

    location / {
            add_header Content-Type text/plain;
            return 200 'lawng';
    }

    location /basic_status {
            stub_status;
    }

}" | sudo tee /etc/nginx/sites-available/default >/dev/null

echo "init_config:

instances:
  - nginx_status_url: http://localhost/basic_status
      tags:
        - instance: foo
" | sudo tee /etc/dd-agent/conf.d/nginx.yaml
