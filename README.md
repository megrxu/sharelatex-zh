# sharelatex-zh

[![](https://img.shields.io/docker/cloud/build/megrxu/sharelatex-zh)](https://hub.docker.com/repository/docker/megrxu/sharelatex-zh)

Supports CJK docs.

## What it does

- Set the timezone (installations of some packages need timezone information).
- Change the mirror and install the common packages.
- Download some other Chinese fonts and then rebuild the font cache using `fc-cache`.

## Using `docker-compose`

- Edit the `docker-compose.yml`.
- Run `docker-compose up`.

<details>
<summary>docker-compose.yml</summary>

```yaml
version: '2.2'
services:
    sharelatex:
        restart: always
        image: megrxu/sharelatex-zh:latest
        container_name: sharelatex
        depends_on:
            mongo:
                condition: service_healthy
            redis:
                condition: service_started
        ports:
            - 12306:80
        links:
            - mongo
            - redis
        volumes:
            - /opt/overleaf-data/sharelatex_data:/var/lib/sharelatex
        environment:

            SHARELATEX_APP_NAME: Overleaf Community Edition

            SHARELATEX_MONGO_URL: mongodb://mongo/sharelatex

            # Same property, unfortunately with different names in
            # different locations
            SHARELATEX_REDIS_HOST: redis
            REDIS_HOST: redis

            ENABLED_LINKED_FILE_TYPES: 'url,project_file'

            # Enables Thumbnail generation using ImageMagick
            ENABLE_CONVERSIONS: 'true'

            # Disables email confirmation requirement
            EMAIL_CONFIRMATION_DISABLED: 'true'

            # temporary fix for LuaLaTex compiles
            # see https://github.com/overleaf/overleaf/issues/695
            TEXMFVAR: /var/lib/sharelatex/tmp/texmf-var

            ## Set for SSL via nginx-proxy
            #VIRTUAL_HOST: 103.112.212.22

            # SHARELATEX_SITE_URL: http://sharelatex.mydomain.com
            # SHARELATEX_NAV_TITLE: Our ShareLaTeX Instance
            # SHARELATEX_HEADER_IMAGE_URL: http://somewhere.com/mylogo.png
            # SHARELATEX_ADMIN_EMAIL: support@it.com

            # SHARELATEX_LEFT_FOOTER: '[{"text": "Powered by <a href=\"https://www.sharelatex.com\">ShareLaTeX</a> 2016"},{"text": "Another page I want to link to can be found <a href=\"here\">here</a>"} ]'
            # SHARELATEX_RIGHT_FOOTER: '[{"text": "Hello I am on the Right"} ]'

            # SHARELATEX_EMAIL_FROM_ADDRESS:
            # SHARELATEX_EMAIL_SMTP_HOST: 
            # SHARELATEX_EMAIL_SMTP_PORT: 
            # SHARELATEX_EMAIL_SMTP_SECURE:
            # SHARELATEX_EMAIL_SMTP_USER:
            # SHARELATEX_EMAIL_SMTP_PASS:
            # SHARELATEX_EMAIL_SMTP_TLS_REJECT_UNAUTH:
            # SHARELATEX_EMAIL_SMTP_IGNORE_TLS:
            # SHARELATEX_CUSTOM_EMAIL_FOOTER:

    mongo:
        restart: always
        image: mongo
        container_name: mongo
        expose:
            - 27017
        volumes:
            - /opt/overleaf-data/mongo_data:/data/db
        healthcheck:
            test: echo 'db.stats().ok' | mongo localhost:27017/test --quiet
            interval: 10s
            timeout: 10s
            retries: 5

    redis:
        restart: always
        image: redis:5
        container_name: redis
        expose:
            - 6379
        volumes:
            - /opt/overleaf-data/redis_data:/data
```

</details>

## Using `systemd`

[Ref](https://github.com/docker/compose/issues/4266#issuecomment-302813256)

- Run `mkdir -p /etc/docker/compose/overleaf`.
- Move `docker-compose.yml` into it.
- Run `systemctl start docker-compose@overleaf`.

<details>
<summary>docker-compose@.service</summary>

```ini
[Unit]
Description=%i service with docker compose
Requires=docker.service
After=docker.service

[Service]
Restart=always

WorkingDirectory=/etc/docker/compose/%i

# Remove old containers, images and volumes
ExecStartPre=/usr/bin/docker-compose down -v
ExecStartPre=/usr/bin/docker-compose rm -fv
ExecStartPre=-/bin/bash -c 'docker volume ls -qf "name=%i_" | xargs docker volume rm'
ExecStartPre=-/bin/bash -c 'docker network ls -qf "name=%i_" | xargs docker network rm'
ExecStartPre=-/bin/bash -c 'docker ps -aqf "name=%i_*" | xargs docker rm'

# Compose up
ExecStart=/usr/bin/docker-compose up

# Compose down, remove containers and volumes
ExecStop=/usr/bin/docker-compose down -v

[Install]
WantedBy=multi-user.target
```
</details>

