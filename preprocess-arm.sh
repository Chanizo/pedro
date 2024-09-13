#!/bin/bash

# Vérifier si un profil est fourni
if [ -z "$1" ]; then
  echo "Usage: $0 <profile>"
  echo "Les profils valides sont : car, bicycle, foot"
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

# Fusionner les fichiers .osm.pbf des régions
MERGED_OSM_FILE="data/donnees-latest-${PROFILE}.osm.pbf"

# Si le fichier fusionné n'existe pas déjà
if [ ! -f "$MERGED_OSM_FILE" ]; then
  echo "Fusion des fichiers .osm.pbf pour créer $MERGED_OSM_FILE..."

  # Boucle pour télécharger les fichiers de chaque région
  for REGION in "${REGIONS[@]}"; do
    OSM_FILE="data/${REGION}-latest.osm.pbf"

    # Télécharger l'extrait OSM si ce n'est pas déjà fait
    if [ ! -f "$OSM_FILE" ]; then
      echo "Téléchargement des données pour $REGION..."
      wget -O "$OSM_FILE" "http://download.geofabrik.de/europe/france/${REGION}-latest.osm.pbf"
    fi
  done

  # Fusion des fichiers OSM avec osmosis ou osmium (selon ce qui est disponible sur ton système)
  if command -v osmosis &> /dev/null; then
    osmosis \
      --read-pbf file="data/provence-alpes-cote-d-azur-latest.osm.pbf" \
      --read-pbf file="data/languedoc-roussillon-latest.osm.pbf" \
      --merge \
      --write-pbf file="$MERGED_OSM_FILE"
  elif command -v osmium &> /dev/null; then
    osmium merge data/*.osm.pbf -o "$MERGED_OSM_FILE"
  else
    echo "Osmosis ou Osmium n'est pas installé. Veuillez installer l'un d'eux pour fusionner les fichiers .osm.pbf."
    exit 1
  fi
fi

# Construction de l'image Docker pour ARM
docker buildx build --platform linux/arm64 -t osrm-backend-arm:latest .

# Exécuter les étapes de prétraitement avec Docker sur le fichier fusionné
echo "Extraction des données pour le profil $PROFILE..."
docker run --rm -v $(pwd)/data:/data osrm-backend-arm:latest osrm-extract -p /opt/${PROFILE}.lua /data/donnees-latest-${PROFILE}.osm.pbf

echo "Partitionnement des données..."
docker run --rm -v $(pwd)/data:/data osrm-backend-arm:latest osrm-partition /data/donnees-latest-${PROFILE}.osrm

echo "Personnalisation des données..."
docker run --rm -v $(pwd)/data:/data osrm-backend-arm:latest osrm-customize /data/donnees-latest-${PROFILE}.osrm

echo "Traitement terminé avec succès pour le profil $PROFILE"
