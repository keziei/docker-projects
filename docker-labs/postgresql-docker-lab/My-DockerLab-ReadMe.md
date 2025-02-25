# Build the machine with dockerfile and cocker-compose.yml in same dir 
docker compose build 
docker compose up -d 

# Check the status of the machine
docker ps
docker logs pg1
psql -h localhost -p 5433 -U postgres -d pagila


# Check the status of the database
docker exec -it pg1 psql -U postgres -d pagila -c "\dt"
docker exec -it pg2 psql -U postgres -d pagila -c "\dt"

# Connect to the host machine
docker exec -it pg1 bash
docker run --rm -it --entrypoint /bin/bash postgresql-docker-lab-pg1

docker restart pg1
docker stop pg1
docker start pg1
docker rm pg1

# Rebuild 
docker compose down -v  # Remove all containers & volumes
docker compose up -d     # Rebuild everything
docker logs pg1 --tail 20

docker run --rm -it --entrypoint /bin/bash postgresql-docker-lab-pg1
