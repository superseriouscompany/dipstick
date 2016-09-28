#!/bin/bash
#
# henoku sets up a heroku-like deploy environment for nodejs
#
#

# Setup server
ssh "root@phoenix.superserious.co" apt-get update -y
ssh "root@phoenix.superserious.co" apt-get upgrade -y
# TODO: http://www.codelitt.com/blog/my-first-10-minutes-on-a-server-primer-for-securing-ubuntu/

# Install nodejs
ssh "root@phoenix.superserious.co" apt-get install -y nodejs
ssh "root@phoenix.superserious.co" ln -s "$(which nodejs)" /usr/bin/node
ssh "root@phoenix.superserious.co" apt-get install -y npm

# Install nginx
ssh "root@phoenix.superserious.co" apt-get install -y nginx

# Setup letsencrypt
ssh "root@phoenix.superserious.co" apt-get install -y letsencrypt
ssh "root@phoenix.superserious.co" letsencrypt certonly -a webroot --webroot-path=/var/www/html -d phoenix.superserious.co --agree-tos --email superseriousneil@gmail.com
ssh "root@phoenix.superserious.co" 'openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048'

# Update nginx to use ssl
echo "ssl_certificate /etc/letsencrypt/live/phoenix.superserious.co/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/phoenix.superserious.co/privkey.pem;" | ssh "root@phoenix.superserious.co" "cat > /etc/nginx/snippets/ssl-phoenix.superserious.co.conf"

echo '# from https://cipherli.st/
# and https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html

ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the "preload" directive if you understand the implications.
#add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
ssl_dhparam /etc/ssl/certs/dhparam.pem;' | ssh "root@phoenix.superserious.co" "cat > /etc/nginx/snippets/ssl-params.conf"

echo 'server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name phoenix.superserious.co;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2 default_server;
    listen [::]:443 ssl http2 default_server;
    include snippets/ssl-phoenix.superserious.co.conf;
    include snippets/ssl-params.conf;

    root /var/www/html;

    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
            proxy_pass http://localhost:3000;
    }

    location ~ /.well-known {
            allow all;
    }
}' | ssh "root@phoenix.superserious.co" "cat > /etc/nginx/sites-available/default"

ssh "root@phoenix.superserious.co" systemctl restart nginx

# Setup git
ssh "root@phoenix.superserious.co" useradd -m -s /usr/bin/git-shell git
ssh "root@phoenix.superserious.co" mkdir -p /home/git/.ssh
ssh "root@phoenix.superserious.co" chown -R git:git /home/git/.ssh
ssh "root@phoenix.superserious.co" mkdir -p /opt/src/dipstick
ssh "root@phoenix.superserious.co" chown -R git:git /opt/src
ssh "root@phoenix.superserious.co" mkdir -p /dipstick.git
ssh "root@phoenix.superserious.co" 'cd /dipstick.git && git init --bare'
ssh "root@phoenix.superserious.co" chown -R git:git /dipstick.git
echo "git ALL=NOPASSWD: /bin/systemctl restart app.service, /bin/systemctl status app.service" | ssh "root@phoenix.superserious.co" "cat > /etc/sudoers.d/git"
ssh "root@phoenix.superserious.co" chmod 0440 /etc/sudoers.d/git
cat ~/.ssh/id_rsa.pub | ssh "root@phoenix.superserious.co" "cat > /home/git/.ssh/authorized_keys"
echo "#!/bin/sh
git --work-tree=/opt/src/dipstick --git-dir=/dipstick.git checkout -f
(cd /opt/src/dipstick && npm install)
sudo /bin/systemctl restart app.service
sudo /bin/systemctl status app.service" | ssh "root@phoenix.superserious.co" "cat > /dipstick.git/hooks/post-receive"
ssh "root@phoenix.superserious.co" "chmod +x /dipstick.git/hooks/post-receive"

# Setup app service
echo "[Unit]
Description=dipstick nodejs app

[Service]
WorkingDirectory=/opt/src/dipstick
ExecStart=/usr/bin/npm start
Restart=always

[Install]
WantedBy=multi-user.target" | ssh "root@phoenix.superserious.co" "cat > /etc/systemd/system/app.service"

ssh "root@phoenix.superserious.co" systemctl enable app
