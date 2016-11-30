echo "server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;

    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
            add_header Content-Type text/plain;
            return 200 'lawng';
    }

    location ~ /.well-known {
            allow all;
    }
}" | sudo tee /etc/nginx/sites-available/default >/dev/null
