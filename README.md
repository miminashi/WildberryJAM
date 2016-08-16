# WildberryJAM

Get in touch with Node-Red running on remote devices from anyware.

## Setup server

Tried Ubuntu 14.04.3 LTS on AWS EC2.

### Install Ruby2.3

```bash
$ sudo apt-get install software-properties-common
$ sudo apt-add-repository ppa:brightbox/ruby-ng
$ sudo apt-get update
$ sudo apt-get install ruby2.3 ruby2.3-dev
$ sudo gem install bundler
```

### Configure WildberryJAM

```bash
$ sudo apt-get install libsqlite3-dev
$ sudo adduser -h /home/jam -s /sbin/nologin -D jam
$ sudo su - jam
$ cd ~/
$ git clone https://github.com/miminashi/WildberryJAM.git
$ cd WildberryJAM
$ bundle install
$ bundle exec rake db:migrate
$ exit  # from jam
```

### Configure Upstart

Create `/etc/init/wildberryjam.conf` with:

```upstart
description "Get in touch with Node-Red running on remote devices from anyware."
author  "jam@localhost"

start on runlevel [2345]
stop on runlevel [016]

chdir /home/jam/WildberryJAM
exec su - jam -c 'cd /home/jam/WildberryJAM && HOST=ec2-xxx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com USER=jam /usr/local/bin/bundle exec rackup'
respawn
```

Start WildberryJAM

```bash
$ sudo initctl reload-configuration
$ sudo initctl start wildberryjam
```

### Install and configure nginx

```bash
$ sudo apt-get install nginx
```

Open `/etc/nginx/sites-available/default`, and replace `server` directive with:

```nginx
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

Reload nginx config

```
sudo service nginx restart
```

### Add Security Group (AWS Only)

Add following rule.

- Inbound 80
- inbound 22

