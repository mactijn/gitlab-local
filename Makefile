# defaults
COMPOSE_FILE := $(PWD)/docker-compose.yml
SERVICE_TIMEOUT := 150

# find docker
DOCKER_BIN := $(shell which docker)
ifeq ($(DOCKER_BIN),)
$(error could not find docker)
endif

DOCKER_COMPOSE_IMAGE := docker/compose:1.21.2
DOCKER_COMPOSE_BIN = $(DOCKER_BIN) run --rm -it -v "$(PWD):$(PWD)" -w "$(PWD)" -v /var/run/docker.sock:/var/run/docker.sock $(DOCKER_COMPOSE_IMAGE)

# native docker-compose
# DOCKER_COMPOSE_BIN := $(shell which docker-compose)


.PHONY: default run stop update destructive-reset logs _/

# default target is to run
default: run

run: _/docker-compose/up
stop: _/docker-compose/down
restart: _/docker-compose/restart
update: _/docker-compose/build _/docker-compose/pull
destructive-reset: _/destructive-reset
reset-from-backup: _/destructive-reset _/gitlab/backup/restore
logtail: _/docker-compose/logs
create-backup: _/gitlab/backup/create
restore-backup: _/gitlab/backup/restore
wait-for-gitlab: _/gitlab/wait-healthy

_/destructive-reset:
	$(DOCKER_COMPOSE_BIN) kill
	$(DOCKER_COMPOSE_BIN) down -v
	rm -rf runner/ gitlab/trusted-certs/
	rm -f gitlab/ssh_host_*_key gitlab/ssh_host_*_key.pub gitlab/gitlab-secrets.json

_/gitlab/run-wait:
	$(MAKE) -j1 _/gitlab/run _/gitlab/wait-healthy

_/gitlab/run:
	$(info The gitlab service will be started, however it might take a while to become available.)
	$(DOCKER_COMPOSE_BIN) up -d gitlab


_/gitlab/wait-healthy:
	$(info Waiting for gitlab to become available (timeout $(SERVICE_TIMEOUT)s)...)
	@set -e; \
  CONTAINER_ID=$(shell $(DOCKER_COMPOSE_BIN) ps -q gitlab); \
	if [ -z "$${CONTAINER_ID}" ]; then \
	  echo 'Container not found: gitlab' >&2; \
		exit 1; \
	fi; \
	TIMEOUT=$(SERVICE_TIMEOUT); \
	until [ "$$($(DOCKER_BIN) inspect -f '{{.State.Health.Status}}' $${CONTAINER_ID})" = "healthy" ]; do \
		[ "$${TIMEOUT}" -le 0 ] && exit 1; \
		TIMEOUT=$$((TIMEOUT - 1)); \
		sleep 1; \
	done

_/gitlab/backup/create: _/gitlab/run-wait
	$(DOCKER_COMPOSE_BIN) exec gitlab gitlab-rake gitlab:backup:create

_/gitlab/backup/restore: _/gitlab/run-wait
	$(DOCKER_COMPOSE_BIN) exec gitlab gitlab-rake gitlab:backup:restore
	$(MAKE) -j1 _/docker-compose/restart

### docker-compose stuff
_/docker-compose/up: _/runner/setup
	$(DOCKER_COMPOSE_BIN) up -d

_/docker-compose/down:
	$(DOCKER_COMPOSE_BIN) down

_/docker-compose/restart:
	$(DOCKER_COMPOSE_BIN) restart

_/docker-compose/pull:
	$(DOCKER_COMPOSE_BIN) pull

_/docker-compose/build:
	$(DOCKER_COMPOSE_BIN) build --pull

_/docker-compose/logs:
	$(DOCKER_COMPOSE_BIN) logs -f


### gitlab-runner stuff
_/runner/setup: runner/config.toml

runner/config.toml: _/gitlab/run-wait
	mkdir -p runner/
	echo "concurrent = 4" > runner/config.toml
	$(DOCKER_COMPOSE_BIN) run -v "$(PWD)/runner:/etc/gitlab-runner" --rm --no-deps --use-aliases \
    runner register \
        --non-interactive \
        --registration-token "DEMO_RUNNER_TOKEN" \
        --url http://gitlab.localhost/ \
        --description 'Runner' \
        --locked=false \
        --executor docker \
        --docker-image docker:latest \
        --docker-volumes '/var/run/docker.sock:/var/run/docker.sock' \
        --docker-extra-hosts gitlab.localhost:10.12.14.16
