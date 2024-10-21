# ----- DOCKER-COMPOSE OPERATIONS -----

.PHONY: explain-dc build build-no-cache up-d up-scale down stop restart pull ps logs exec start-app sass fuser

explain-dc:
	@echo "\n--- Services in docker-compose.yml ---"
	@yq e '.services | keys | .[]' docker-compose.yml
	@echo "\n--- Global settings in docker-compose.yml ---"
	@yq e '.x-common-service-properties' docker-compose.yml
	@echo "\n--- Details for each service ---"
	@for service in $$(yq e '.services | keys | .[]' docker-compose.yml); do \
		echo "\n==> Service: $$service"; \
		yq e ".services.$$service" docker-compose.yml; \
	done
	@echo "\n--- Networks in docker-compose.yml ---"
	@yq e '.networks' docker-compose.yml

build:
	@docker compose --profile=$(service) build

build-no-cache:
	@docker compose --profile=$(service) build --no-cache

up-d:
	@docker compose --profile=$(service) up -d --remove-orphans

up-scale:
	@docker compose --profile=$(service) up --scale $(service)=$(SCALE) -d

down:
	@docker compose --profile=$(service) down --remove-orphans

stop:
	@docker compose --profile=$(service) stop

restart:
	@docker compose --profile=$(service) restart

pull:
	@docker compose --profile=$(service) pull

ps:
	@docker compose --profile=$(service) ps

logs:
	@docker compose --profile=$(service) logs -f

exec:
	@docker compose --profile=$(service) exec $(service) $(CMD)

start-app: build down up-d

sass:
	@sass --style=compressed src/css/ndexrio.scss src/css/ndexrio.css

fuser:
	@sudo fuser -k 8000/tcp

style:
	R -e "styler::style_dir()"

start: style sass 
	Rscript app.r

push:	style
	git add --all
	git commit -m 'save'
	git push

pull:
	git pull


