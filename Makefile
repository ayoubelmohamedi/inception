NAME = inception

# Define the path variables (you can change this for the VM later)
DATA_PATH = $(HOME)/data

all:
    @# 1. Create the directories on the host machine
    @mkdir -p $(DATA_PATH)/wordpress
    @mkdir -p $(DATA_PATH)/mariadb
    
    @# 2. Start Docker Compose
    @docker-compose -f srcs/docker-compose.yml up -d --build

down:
    @docker-compose -f srcs/docker-compose.yml down

clean:
    @docker-compose -f srcs/docker-compose.yml down -v
    @# Optional: Clean up data folders (be careful!)
    @# rm -rf $(DATA_PATH)

re: clean all

.PHONY: all down clean re