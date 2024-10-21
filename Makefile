# Default values
proj     ?= ndexr
env      ?= dev
service  ?=
profile  ?=
number   ?= 1
no_cache ?=
domain   ?=

# Specify the project folder (now always srv)
folder := srv
COMPOSE_FILE := -f ./$(folder)/$(proj)/compose.yml -f ./$(folder)/$(proj)/compose.$(env).yml -p ${proj}-$(env)

# Check if docker-compose or docker compose is available
ifneq (,$(shell which docker-compose))
  DOCKER_COMPOSE_CMD := docker-compose
else ifneq (,$(shell docker compose version > /dev/null 2>&1 && echo $$?))
  DOCKER_COMPOSE_CMD := docker compose
else
  $(error Neither docker-compose nor docker compose found)
endif

DOCKER_COMPOSE := $(DOCKER_COMPOSE_CMD) $(if $(profile),--profile $(profile)) $(COMPOSE_FILE)

# Common tasks
.PHONY: start stop down build restart pull push logs validate buildssh clean

# Logs of the service(s)
logs:
	$(DOCKER_COMPOSE) logs -f $(service)

up stop restart pull push down:
ifdef service
	@if [ "$@" = "up" ]; then \
		if [ "$(service)" = "certbot" ] && [ -n "$(domain)" ]; then \
			DOMAIN=$(domain) $(DOCKER_COMPOSE) $@ $(service) -d; \
		else \
			$(DOCKER_COMPOSE) $@ $(service) -d; \
		fi \
	elif [ "$@" = "down" ]; then \
		$(DOCKER_COMPOSE) $@ $(service); \
	else \
		$(DOCKER_COMPOSE) $@ $(service); \
	fi
else
	@if [ "$@" = "up" ]; then \
		$(DOCKER_COMPOSE) $@ -d; \
	elif [ "$@" = "down" ]; then \
		$(DOCKER_COMPOSE) $@ --remove-orphans; \
	else \
		$(DOCKER_COMPOSE) $@; \
	fi
endif

# Build with possible no-cache option
build buildnc:
ifdef service
	$(DOCKER_COMPOSE) build  $(service)
else
	$(DOCKER_COMPOSE) build $(if $(findstring buildnc,$@),--no-cache)
endif

buildssh:
	$(DOCKER_COMPOSE) build --ssh default $(if $(findstring buildnc,$@),--no-cache) $(service)

# Scale multiple services and display commands
scale:
ifdef service
	@echo "Scaling services: $(service)"
	$(DOCKER_COMPOSE) up $(foreach srv,$(service),--scale $(srv)=$(number)) --no-recreate -d
else
	@$(error "service is undefined. Please specify one or more services via service=SERVICE1 SERVICE2 ...")
endif

# Show environment variables and Docker Compose configuration files
validate:
ifndef proj
	$(error "proj is undefined. Please specify a project name via proj=PROJECT_NAME.")
endif
ifndef env
	$(error "env is undefined. Please specify an environment via env=ENVIRONMENT.")
endif
	@echo "Validating..."
	@if [ ! -f "./$(folder)/$(proj)/$(proj).$(env).yml" ]; then \
		echo "No Docker Compose file found for project: $(proj), environment: $(env). Please check your file paths and names."; \
		exit 1; \
	fi

gateway:
	make build down up proj=gateway # >> ~/ndexr.log 2>&1&

ndex: 
	git pull | echo "Nothing to pull"
	make build down up proj=ndexr
	make scale proj=ndexr service=console number=3

bmn: 
	git pull | echo "Nothing to pull"
	make build down up proj=bmrn
	
template:
	sh template.sh

ndexr:	
	cp find_files.sh ../.
	make ndex >> ~/ndexr.log 2>&1&

evalssh:
	eval "$(ssh-agent -s)"

stopall:
	docker ps -aq | xargs docker stop | xargs docker rm

pkill:
	sudo kill -9 $(sudo lsof -t -i:8000)

# Clean up unused Docker resources
clean:
	@docker system prune -f
	@docker volume prune -f
	@docker network prune -f

nlogs:
	make logs proj=ndexr


public:
	cp -r srv/apps ../ndexr-public/srv/.
	cp -r srv/router ../ndexr-public/srv/.
	cp Makefile ../ndexr-public/.
	cp find_files.sh ../ndexr-public/.

