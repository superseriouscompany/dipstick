#!/bin/bash
#
# henoku sets up a heroku-like deploy environment for nodejs
#
#
HOST=test2.superserious.co
LETSENCRYPT_EMAIL=superseriousneil@gmail.com
RUN_COMMAND="/usr/bin/npm start"

# TODO: use digitalocean api and cloudflare api to create the host

# Setup server
ssh "root@$HOST" apt-get update -y
ssh "root@$HOST" apt-get upgrade -y

# Create user to ssh in with from this computer
username="$(whoami)"
ssh "root@$HOST" useradd -s /bin/bash "$username"
ssh "root@$HOST" mkdir /home/"$username"
ssh "root@$HOST" mkdir /home/"$username"/.ssh
ssh "root@$HOST" chmod 700 /home/"$username"/.ssh
ssh "root@$HOST" cp /root/.ssh/authorized_keys /home/"$username"/.ssh/authorized_keys
ssh "root@$HOST" chown "$username":"$username" -R /home/"$username"
ssh "root@$HOST" usermod -aG sudo neilsarkar
echo "echo \"$username:nope\" | chpasswd" | ssh "root@$HOST"

# Setup firewall
ssh "root@$HOST" ufw allow 22
ssh "root@$HOST" ufw allow 80
ssh "root@$HOST" ufw allow 443
ssh "root@$HOST" ufw disable
ssh "root@$HOST" ufw enable

# Install nodejs
ssh "root@$HOST" apt-get install -y nodejs
ssh "root@$HOST" ln -s "$(which nodejs)" /usr/bin/node
ssh "root@$HOST" apt-get install -y npm

# Install nginx
ssh "root@$HOST" apt-get install -y nginx

# Setup letsencrypt
ssh "root@$HOST" apt-get install -y letsencrypt
ssh "root@$HOST" letsencrypt certonly -a webroot --webroot-path=/var/www/html -d $HOST --agree-tos --email $LETSENCRYPT_EMAIL
ssh "root@$HOST" openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# Update nginx to use ssl
echo "ssl_certificate /etc/letsencrypt/live/$HOST/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/$HOST/privkey.pem;" | ssh "root@$HOST" "cat > /etc/nginx/snippets/ssl-$HOST.conf"

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
' | ssh "root@$HOST" "cat > /etc/nginx/snippets/ssl-params.conf"
# TODO: readd this to above ssl_dhparam /etc/ssl/certs/dhparam.pem;

echo "server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name $HOST;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2 default_server;
    listen [::]:443 ssl http2 default_server;
    include snippets/ssl-$HOST.conf;
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
}" | ssh "root@$HOST" "cat > /etc/nginx/sites-available/default"

ssh "root@$HOST" systemctl restart nginx

# Setup git
ssh "root@$HOST" useradd -m -s /usr/bin/git-shell git
ssh "root@$HOST" mkdir -p /home/git/.ssh
ssh "root@$HOST" chown -R git:git /home/git/.ssh
ssh "root@$HOST" mkdir -p /opt/src/dipstick
ssh "root@$HOST" chown -R git:git /opt/src
ssh "root@$HOST" mkdir -p /dipstick.git
ssh "root@$HOST" 'cd /dipstick.git && git init --bare'
ssh "root@$HOST" chown -R git:git /dipstick.git
echo "git ALL=NOPASSWD: /bin/systemctl restart app.service, /bin/systemctl status app.service" | ssh "root@$HOST" "cat > /etc/sudoers.d/git"
ssh "root@$HOST" chmod 0440 /etc/sudoers.d/git
cat ~/.ssh/id_rsa.pub | ssh "root@$HOST" "cat > /home/git/.ssh/authorized_keys"
echo "#!/bin/sh
git --work-tree=/opt/src/dipstick --git-dir=/dipstick.git checkout -f
(cd /opt/src/dipstick && npm install)
sudo /bin/systemctl restart app.service
sudo /bin/systemctl status app.service" | ssh "root@$HOST" "cat > /dipstick.git/hooks/post-receive"
ssh "root@$HOST" "chmod +x /dipstick.git/hooks/post-receive"

# Setup app service
echo "[Unit]
Description=dipstick nodejs app

[Service]
WorkingDirectory=/opt/src/dipstick
ExecStart=$RUN_COMMAND
Restart=always

[Install]
WantedBy=multi-user.target" | ssh "root@$HOST" "cat > /etc/systemd/system/app.service"

ssh "root@$HOST" systemctl enable app

echo "git@$HOST/dipstick.git"
