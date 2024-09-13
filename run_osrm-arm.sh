#!/bin/bash

docker buildx build --platform linux/arm64 -f Dockerfile.run -t osrm-backend-arm-run:latest .

# Lancer le serveur OSRM avec docker-compose
docker-compose -f docker-compose-run-osrm.yml up -d
