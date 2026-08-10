## Hearth

[![MIT License](https://img.shields.io/badge/license-MIT-9370d8.svg?style=flat)](https://opensource.org/licenses/MIT)

This repository contains the [Docker Compose](https://docs.docker.com/compose/) file for running the Docker containers needed by Hearth. The source code for the application itself is split between the [backend](https://github.com/hearthweb/backend) and [frontend](https://github.com/hearthweb/frontend) repositories.

### Setup

Begin by copying the `.env.template` file to `.env` and providing values where required. At a minimum, you will need to specify `DB_PASSWORD` and `SECRET_KEY`. If you leave `DATA_DIR` unset, a `data/` directory will be created in the root of your repository for storing application data.

Next, create and start the containers with:

```
docker compose create
docker compose start
```

Once all of the containers have started, initialize the database and create an admin user with:

```
docker exec -it app-backend-1 python3 cli.py init-db
docker exec -it app-backend-1 python3 cli.py create-admin
```
