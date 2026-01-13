LOGIN = ielmoudd
YML_FILE = ./srcs/docker-compose.yml
DATA_DIR = /home/$(LOGIN)/data

all: up

setup_ssl:
	@if [ ! -f secrets/nginx_key.txt ]; then \
		openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout secrets/nginx_key.txt \
		-out secrets/nginx_crt.txt \
		-subj "/C=MA/ST=Rabat/L=Sale/O=1337/OU=Student/CN=ielmoudd.42.fr"; \
	fi

goacess_files:
	@mkdir -p srcs/requirements/nginx/logs
	@if [ ! -f srcs/requirements/nginx/logs/access.log ]; then \
		touch srcs/requirements/nginx/logs/access.log; \
	fi
	@if [ ! -f srcs/requirements/nginx/logs/error.log ]; then \
		touch srcs/requirements/nginx/logs/error.log; \
	fi

up: setup_ssl goacess_files
	@docker compose -f $(YML_FILE) up -d --build

down:
	@echo "Makefile: Stopping the containers"
	@docker compose -f $(YML_FILE) down

clean: down
	@docker compose -f $(YML_FILE) down -v
	@docker system prune -af

re: clean all

logs:
	@docker compose -f ./srcs/docker-compose.yml logs

ps:
	@docker ps

.PHONY: all up down clean re ps logs setup_ssl