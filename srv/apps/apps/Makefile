env ?= dev
proj = $(notdir $(CURDIR))

# Defining docker-compose file sequence
COMPOSE_FILE = -f ./$(proj).yml -f ./$(proj).$(env).yml

# Determining docker-compose command availability
DOCKER_COMPOSE_CMD := $(shell command -v docker-compose 2> /dev/null)

# Fallback to use docker compose (for Docker Desktop 3.2.1+)
ifeq ($(DOCKER_COMPOSE_CMD),)
    DOCKER_COMPOSE_CMD := $(shell command -v docker 2> /dev/null) compose
endif

# Error if neither command is found
ifeq ($(DOCKER_COMPOSE_CMD),)
    $(error Neither docker-compose nor docker compose found in PATH. Please install Docker.)
endif

# Defining docker-compose alias
DOCKER_COMPOSE := $(DOCKER_COMPOSE_CMD) $(COMPOSE_FILE)

# Basic Docker Compose actions

## Start the containers
start:
	$(DOCKER_COMPOSE) up -d

## Stop the containers
stop:
	$(DOCKER_COMPOSE) down

## Build the containers
build:
	$(DOCKER_COMPOSE) build

## Build the containers without cache
build-no-cache:
	$(DOCKER_COMPOSE) build --no-cache

## Restart the containers
restart:
	$(DOCKER_COMPOSE) restart

## Display useful files for troubleshooting
display-files:
	@echo "Configuration files and other notable files for $(proj) in environment $(env):"
	@find . -name "$(proj)*.yml" -or -name "Dockerfile"
	@echo "\nService directories:"
	@ls -d services/*

## Display help message
help:
	@echo "Usage: make [COMMAND] [env=ENV_NAME]"
	@echo "\nCommands:"
	@echo "  start            Start the containers"
	@echo "  stop             Stop the containers"
	@echo "  build            Build the containers"
	@echo "  build-no-cache   Build the containers without using cache"
	@echo "  restart          Restart the containers"
	@echo "  display-files    Display relevant files for troubleshooting"
