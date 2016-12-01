echo "server {
    listen 80 default_server;
    server_name _;

    location / {
            add_header Content-Type text/plain;
            return 200 'lawng';
    }
}" | sudo tee /etc/nginx/sites-available/default >/dev/null
