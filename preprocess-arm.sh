#!/bin/bash

# Vérifier si un profil est fourni
if [ -z "$1" ]; then
  echo "Usage: $0 <profile>"
  exit 1
fi

PROFILE=$1

# Vérifier si le profil est valide
if [[ "$PROFILE" != "car" && "$PROFILE" != "bicycle" && "$PROFILE" != "foot" ]]; then
  echo "Profil invalide : $PROFILE"
  echo "Les profils valides sont : car, bicycle, foot"
  exit 1
fi

echo "execution avec le profile $PROFILE"

# Créer le dossier data si ce n'est pas déjà fait
mkdir -p data

# osrm-extract n'accepte pas d'option pour spécifier le nom du fichier d'output
# on utilise copie donc le fichier de base avec un nouveau nom, les liens symboliques ne marchent pas (à creuser)
if [ ! -f data/provence-alpes-cote-d-azur-latest-${PROFILE}.osm.pbf ]; then
  # Télécharger l'extrait OSM si ce n'est pas déjà fait
  if [ ! -f data/provence-alpes-cote-d-azur-latest.osm.pbf ]; then
    wget -O data/provence-alpes-cote-d-azur-latest.osm.pbf http://download.geofabrik.de/europe/france/provence-alpes-cote-d-azur-latest.osm.pbf
  fi
  cp data/provence-alpes-cote-d-azur-latest.osm.pbf data/provence-alpes-cote-d-azur-latest-${PROFILE}.osm.pbf
fi

docker buildx build --platform linux/arm64 -t osrm-backend-arm:latest .

# Exécuter les étapes de prétraitement avec Docker
docker run --rm -v ./data:/data osrm-backend-arm:latest osrm-extract -p /opt/${PROFILE}.lua /data/provence-alpes-cote-d-azur-latest-${PROFILE}.osm.pbf
docker run --rm -v ./data:/data osrm-backend-arm:latest osrm-partition /data/provence-alpes-cote-d-azur-latest-${PROFILE}.osrm
docker run --rm -v ./data:/data osrm-backend-arm:latest osrm-customize /data/provence-alpes-cote-d-azur-latest-${PROFILE}.osrm
