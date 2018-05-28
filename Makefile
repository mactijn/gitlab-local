# defaults
COMPOSE_FILE := $(PWD)/docker-compose.yml
SERVICE_TIMEOUT := 300 # gitlab can take its time during migrations.

# find docker
DOCKER_BIN := $(shell which docker)
ifeq ($(DOCKER_BIN),)
$(error could not find docker)
endif

DOCKER_COMPOSE_IMAGE := docker/compose:1.21.2

# native docker-compose
DOCKER_COMPOSE_BIN := $(shell which docker-compose)
ifeq ($(DOCKER_COMPOSE_BIN),)
DOCKER_COMPOSE_BIN = $(DOCKER_BIN) run --rm -it -v "$(PWD):$(PWD)" -w "$(PWD)" -v /var/run/docker.sock:/var/run/docker.sock $(DOCKER_COMPOSE_IMAGE)
endif


.PHONY: default run stop update destructive-reset logs _/* _/*/* _/*/*/*

# default target is to run
default: run

run: _/docker-compose/up
stop: _/docker-compose/down
restart: _/docker-compose/restart
update: _/docker-compose/build _/docker-compose/pull _/docker-compose/up
destructive-reset: _/destructive-reset
reset-from-backup: _/destructive-reset _/gitlab/backup/restore
logtail: _/docker-compose/logs
create-backup: _/gitlab/backup/create
restore-backup: _/gitlab/backup/restore
wait-for-gitlab: _/gitlab/wait-healthy
runner: _/runner/setup _/runner/start

_/destructive-reset:
	$(DOCKER_COMPOSE_BIN) kill
	$(DOCKER_COMPOSE_BIN) down -v
	rm -rf runner/ gitlab/trusted-certs/
	rm -f gitlab/ssh_host_*_key gitlab/ssh_host_*_key.pub gitlab/gitlab-secrets.json

### gitlab stuff

_/gitlab/start-wait:
	$(MAKE) -j1 _/gitlab/start _/gitlab/wait-healthy

_/gitlab/start:
	$(info The gitlab service will be started, however it might take a while to become available.)
	$(DOCKER_COMPOSE_BIN) up -d gitlab

_/gitlab/stop:
	$(DOCKER_COMPOSE_BIN) stop gitlab

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

_/gitlab/backup/create: _/gitlab/start-wait
	$(DOCKER_COMPOSE_BIN) exec gitlab gitlab-rake gitlab:backup:create

_/gitlab/backup/restore: _/gitlab/start-wait
	$(DOCKER_COMPOSE_BIN) exec gitlab gitlab-rake gitlab:backup:restore
	$(DOCKER_COMPOSE_BIN) exec gitlab gitlab-rake gitlab:shell:setup
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


### runner stuff

_/runner/setup:
	$(MAKE) -j1 _/gitlab/start-wait runner/config.toml

_/runner/start:
	$(DOCKER_COMPOSE_BIN) up -d runner

_/runner/stop:
	$(DOCKER_COMPOSE_BIN) stop runner

runner/config.toml:
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
