upstream dfe702f4-12f8-47ca-a22c-36dba97fced4 {
    ip_hash;
    server localhost:9040;
    server localhost:9041;
    server localhost:9042;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    #ipv6 listen [::]:80 ipv6only=off;

    server_name fdrennan.com;

    location /.well-known/acme-challenge/ {
       root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    #ipv6 listen [::]:443 ssl ipv6only=off;
    
    server_name fdrennan.com;
    
    large_client_header_buffers 4 32k;

    location /.well-known/acme-challenge/ {
       root /var/www/certbot;
    }

    location / {
        proxy_pass http://dfe702f4-12f8-47ca-a22c-36dba97fced4;
        include conf.d/common_proxy.conf;
    }
    
    # Add the path to your SSL certificate and key
    ssl_certificate /etc/letsencrypt/live/fdrennan.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/fdrennan.com/privkey.pem;
    
    location /rstudio/ {
        # Use this line to allow a specific IP
        allow 98.194.199.125;
        deny all;
        proxy_pass http://localhost:8787/;
        include conf.d/common_proxy.conf;
    }

    location /glances/ {
        deny all;

        proxy_pass http://localhost:61208/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_read_timeout 600s;
        proxy_buffering off;
    }

    location /code/ {
        deny all;

        proxy_pass http://localhost:8080/;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
    }
}
