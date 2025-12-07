# Inception
Docker project, production-like infrastructure using containers that work together seamlessly.


## specs  

2 volumes 

Wordpress database 
Wordpress content /html

Volumes path :  /home/login/data
(Replace login with yours )


!!  The latest tag is prohibited

!! better use Docker secrets to store any
confidential information.

!! NGINX is sole entry point in infrastructure accessible only via port 443
Using the TLSv1.2
or TLSv1.3 protocol.


docker-network
To establish connection 


# Commands : 

Docker stop  <container name>


1- docker stop $(docker ps -aq)

Wipe command
2- docker system prune -a --volumes


docker rmi -f $(docker images -q)
docker volume ls

docker volume prune -f 

Docker container ls -a 

Docker rm -f «  names of containers …»


Access : 
docker exec -it cool_jemison mariadb -u root -p

Docker compose :

// run with build to avoid cache 
// preferable with -d for detach mode .
 {
 docker-compose up --build mariadb
}
{
// or even better , delete volumes 
	
docker compose down -v
docker compose up --build maridocker compose down -v
docker compose up --build mariadb
}
docker compose build 

 (For clean build) => docker compose build --no-cache

(Build & start ) docker compose up --build

— to start containers 
docker compose up -d 
docker compose up -d <image name>


Note .: 
Two restart :
docker restart mariadb (data persist )
docker-compose down - up (needs volumes to persist)

Restart all (nuclear) : 
docker compose down -v --rmi all --remove-orphans
NOTE : --rmi all : (delete) all images 
docker compose up --build --force-recreate



Check if has volume docker inspect -f '{{ .Mounts }}' <container name>


Cleanups to watch for: 
{{{
Ghost are layers replaced by newer build. No longer needed, yet take space.

Ghost (dangling images):  
To list : docker images -f "dangling=true"
To rm : docker system prune  —dry-run

Orphan containers: 
Containers hold the name of the project (docker compose),
Yet no longer exists there. 
To list : docker compose ps -a
To rm : docker compose down —remove-orphans

// safer way to delete orphans 
docker compose up -d --remove-orphans
}}}


Mariadb :

SHOW DATABASES;
USE wordpress; // select database 
SHOW TABLES;


