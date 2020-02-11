# RagerX Pool Install Instructions

This repo outlines the steps to set up a RagerX compatible pool. You should contact the RagerX team through [Telegram](https://t.me/ragerxlol) or [Reddit](https://reddit.com/r/ragerx) before proceeding with this guide.

## Basics

### Linux User Account

It is recommended to set up a new user account for running the pool frontend.
```
sudo useradd -s /usr/sbin/nologin -rm pool
```

### Postgres

RagerX uses postgres as its database, so first you'll need to install it and set up a new user / database. The below assumes you will use set up a user and database with the name `monero_foss` and password `password`. Make sure to change these values!

```
sudo apt install postgresql

sudo su postgres
psql
CREATE ROLE monero_foss WITH LOGIN PASSWORD 'password';
CREATE DATABASE monero_foss OWNER monero_foss;
\c monero_foss
CREATE SCHEMA AUTHORIZATION monero_foss;
\q
```

Ensure you're able to login with the new credentials with:
```
psql -h 127.0.0.1 -U monero_foss -d monero_foss -W
```

Import the schema:
```
psql -h 127.0.0.1 -U monero_foss -d monero_foss -W < schema.sql
```

To allow remote connections to postgres, you'll need to bind it on all interfaces:
```
sudo nano /etc/postgresql/10/main/postgresql.conf

listen_addresses = '*'            # what IP address(es) to listen on;
```

As well as allow authentication to the database by password from the main ragerx server:
```
sudo nano /etc/postgresql/10/main/pg_hba.conf

host monero_pplnspool monero_pplnspool 81.19.208.43/32 md5
```

### Node.js

You will need node.js to run the pool frontend. It is highly recommended to use `nvm` to do this instead of installing node from your distro's package manager:

```
sudo -u pool -Hs /bin/bash

cd ~
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
source .nvm/nvm.sh
nvm install v12
npm install -g yarn
```

### Python

Python is required to run the payout script. Pipenv is used:

```
sudo apt install python-pip python3-setuptools python3-distutils

sudo -u pool -Hs /bin/bash
pip install --user pipenv
```

## Install Components

### Pool API

Install, configure, and build the pool api server. See [ragerx-foss-frontend-api](https://github.com/ragerxlol/ragerx-foss-frontend-api) docs for more info.

```
sudo -u pool -Hs /bin/bash

cd ~
git clone https://github.com/ragerxlol/ragerx-foss-frontend-api.git
cd ragerx-foss-frontend-api

cp config.example.json config.json
nano config.json

yarn
yarn build
```

### Pool Frontend

Install, configure, and build the pool frontend. See [ragerx-foss-frontend-vue](https://github.com/ragerxlol/ragerx-foss-frontend-vue) docs for more info.

```
sudo -u pool -Hs /bin/bash

cd ~
git clone https://github.com/ragerxlol/ragerx-foss-frontend-vue.git
cd ragerx-foss-frontend-vue

cp config.example.json config.json
nano config.json

yarn
yarn build
```

### Payoutd

Install and configure the payout script. See [ragerx-foss-payoutd](https://github.com/ragerxlol/ragerx-foss-payoutd) docs for more info.

```
sudo -u pool -Hs /bin/bash

cd ~
git clone https://github.com/ragerxlol/ragerx-foss-payoutd.git
cd ragerx-foss-payoutd

../.local/bin/pipenv install
../.local/bin/pipenv shell

cp config.example.json config.json
nano config.json
```

## Deployment

### Systemd

It's recommended to use systemd to start / stop the API and Payoutd. Copy [foss-api.service](deployment/foss-api.service) unit file to `/etc/systemd/system/foss-api.service`, and [payoutd.service](deployment/payoutd.service) unit file to `/etc/systemd/system/payoutd.service`. Enable and start both services. You can test if the API is running with:

```
curl http://localhost:8227/global/stats
```

### Nginx

Use nginx to serve the frontend and proxy requests to the API. Copy the [nginx-example.conf](deployment/nginx-example.conf) file to `/etc/nginx/sites-available/pool.conf` and enable it with:

```
sudo apt install nginx
sudo ln -s /etc/nginx/sites-available/pool.conf /etc/nginx/sites-enabled/pool.conf
sudo nginx -t
sudo systemctl restart nginx
```

You should also use `certbot` to obtain an SSL/TLS certificate. Refer to [this guide](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-18-04).

### iptables / ufw

While not covered in this README, you should also set up a firewall. The final pool will only need 80 / 443 open.

### Logrotate

Ensure that all log files are rotated. Each of the components listens for a SIGHUP and re-opens its log file. Copy [logrotate](deployment/logrotate) file to `/etc/logrotate.d/pool`.

### Contributing

Feel free to send PRs with improvements or other features.

### License

This code is released under the BSD-3-Clause license.
