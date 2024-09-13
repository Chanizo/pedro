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

echo "Exécution avec le profil $PROFILE"

# Liste des régions à télécharger et traiter
REGIONS=("provence-alpes-cote-d-azur" "languedoc-roussillon")  # Ajoute d'autres régions ici si besoin

# Créer le dossier data si ce n'est pas déjà fait
mkdir -p data

# Boucle sur les régions pour télécharger et préparer les fichiers
for REGION in "${REGIONS[@]}"; do
  OSM_FILE="data/${REGION}-latest.osm.pbf"
  PROFILE_OSM_FILE="data/${REGION}-latest-${PROFILE}.osm.pbf"

  # Télécharger l'extrait OSM si ce n'est pas déjà fait
  if [ ! -f "$OSM_FILE" ]; then
    echo "Téléchargement des données pour $REGION..."
    wget -O "$OSM_FILE" "http://download.geofabrik.de/europe/france/${REGION}-latest.osm.pbf"
  fi

  # Créer le fichier spécifique au profil si non existant
  if [ ! -f "$PROFILE_OSM_FILE" ]; then
    echo "Préparation du fichier pour $REGION avec le profil $PROFILE..."
    cp "$OSM_FILE" "$PROFILE_OSM_FILE"
  fi

  # Construction de l'image Docker pour ARM
  docker buildx build --platform linux/arm64 -t osrm-backend-arm:latest .

  # Exécuter les étapes de prétraitement avec Docker
  echo "Extraction des données pour $REGION avec le profil $PROFILE..."
  docker run --rm -v $(pwd)/data:/data osrm-backend-arm:latest osrm-extract -p /opt/${PROFILE}.lua /data/${REGION}-latest-${PROFILE}.osm.pbf

  echo "Partitionnement des données pour $REGION..."
  docker run --rm -v $(pwd)/data:/data osrm-backend-arm:latest osrm-partition /data/${REGION}-latest-${PROFILE}.osrm

  echo "Personnalisation des données pour $REGION..."
  docker run --rm -v $(pwd)/data:/data osrm-backend-arm:latest osrm-customize /data/${REGION}-latest-${PROFILE}.osrm
done
