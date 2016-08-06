# WildberryJAM

Access to Node-Red running remote IoT devices

## Configure nginx

```
server {
        listen 9000;

        location /red/ {
                rewrite ^/red/(\d+)/(.*) /$2 break;
                proxy_pass http://127.0.0.1:$1/$2;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
        }

        location / {
                proxy_pass http://127.0.0.1:9292/;
        }
}
```
