# 🚀 Coolify + Moodle Docker Image

This is a production-ready Docker image for the [Moodle LMS](https://moodle.org), specifically optimized for [Coolify](https://coolify.io). It comes preconfigured with Nginx, supports multiple databases (PostgreSQL/MySQL), and includes all the essential tools for a fully operational Moodle setup.

## Key Features

✔️ **Flexible PHP Support:** Select your preferred PHP version using tags (e.g., php8.2, php8.3)

✔️ **Database Agnostic:** Compatible with both PostgreSQL and MySQL/MariaDB

✔️ **Preinstalled Tools:** Comes with EXIFTOOL, Ghostscript, Python, Graphviz (DOT), pdftoppm, and aspell

✔️ **Secure & Scalable:** Features an isolated Python virtual environment, health checks, and is volume-ready

✔️ **Plug-and-Play:** Simply add your config.php and deploy

### Ideal for

- One-click Moodle installations using Coolify

- Custom Moodle development and staging environments

- Automated scaling with Kubernetes or Docker Swarm

## How it works

### 1. Build the image

```bash
 docker compose build --no-cache --build-arg PHP_VERSION=8.4 --build-arg MOODLE_VERSION=500
```

To find which PHP version is supported by the Moodle version, please see [Moodle releases](https://moodledev.io/general/releases).

In this context, the Moodle version value is "500," which is used in [Git branches](https://github.com/moodle/moodle/branches) and refers to Moodle version 5.0.x.

### 2. See the image generated docker image name

```bash
 docker images
```

You will see "moodle_coolify_app" and "latest" in the REPOSITORY and TAG columns.

### 3. Create a Docker Compose YAML for the Coolify service

```yaml
services:
  app:
    image: 'moodle_coolify_app:latest'
    environment:
      - SERVICE_FQDN_APP
      - MOODLE_WWWROOT=$SERVICE_FQDN_APP
      - MOODLE_DB_TYPE=pgsql
      - MOODLE_DB_HOST=db
      - MOODLE_DB_NAME=moodle
      - MOODLE_DB_USER=$SERVICE_USER_POSTGRES
      - MOODLE_DB_PASS=$SERVICE_PASSWORD_POSTGRES
      - MOODLE_ADMIN_USER=admin
      - MOODLE_ADMIN_PASS=admin
      - MOODLE_ADMIN_EMAIL=admin@example.com
      - MOODLE_SUPPORT_EMAIL=support@example.com
      - MOODLE_FULLNAME=Coolify Moodle
      - MOODLE_SHORTNAME=Coolify
    depends_on:
      - db
    volumes:
      - 'moodlecode:/var/www/html'
      - 'moodledata:/var/www/html/moodledata'
  db:
    image: 'postgres:14'
    container_name: moodle_db
    environment:
      - POSTGRES_DB=moodle
      - POSTGRES_USER=$SERVICE_USER_POSTGRES
      - POSTGRES_PASSWORD=$SERVICE_PASSWORD_POSTGRES
    volumes:
      - 'db_data:/var/lib/postgresql/data'
    restart: unless-stopped
```

#### Pull image from the Docker Hub

Suppose you want to use the Docker image right away. You can pull it from the Docker hub:

```yaml
services:
  app:
    image: 'docker.io/klanjabrik/coolify-moodle:500_latest'
    ...
```

Visit the [Docker Hub page](https://hub.docker.com/r/klanjabrik/coolify-moodle/tags) for more complete tags.

#### Environment Variables

| Environment Variable | Mandatory | Allowed values       | Default                                  | Notes |
|----------------------|-----------|--------------------- |------------------------------------------|-------|
| MOODLE_DB_TYPE       | yes       | pgsql/mysqli/mariadb | none                                     |       |
| MOODLE_DB_HOST       | yes       | any valid hostname   | none                                     |       |
| MOODLE_DB_PORT       | no        | any integer value    | PostgreSQL: 5432,<br>MySQL/MariaDB: 3306 |       |
| MOODLE_DB_NAME       | yes       | any value            | none                                     |       |
| MOODLE_DB_USER       | yes       | any value            | none                                     |       |
| MOODLE_DB_PASS       | yes       | any value            | none                                     |       |
| MOODLE_WWWROOT       | yes       | any valid URL        | none                                     |       |
| MOODLE_ADMIN_USER    | no        | any value            | admin                                    |       |
| MOODLE_ADMIN_PASS    | no        | any value            | admin                                    |       |
| MOODLE_ADMIN_EMAIL   | no        | any valid value      | admin@example.com                        |       |
| MOODLE_SUPPORT_EMAIL | no        | any valid value      | support@example.com                      |       |
| MOODLE_FULLNAME      | no        | any value            | Moodle                                   |       |
| MOODLE_SHORTNAME     | no        | any value            | moodle                                   |       |

### 4. Run the service

```bash
docker compose up -d
```
