
NAME = inception

DATA_PATH=/home/ael-moha/data

all:
	@mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb
	@docker compose -f srcs/docker-compose.yml up -d --build

down:
	@docker compose -f srcs/docker-compose.yml down

clean:
	@docker compose -f srcs/docker-compose.yml down -v

delete_data:
	@rm -rf $(DATA_PATH)

fclean: clean delete_data

re: fclean all

logs:
	@docker compose -f srcs/docker-compose.yml logs -f

ps:
	@docker compose -f srcs/docker-compose.yml ps

.PHONY: all down clean delete_data fclean re logs ps