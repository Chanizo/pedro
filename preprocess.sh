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

# Liste des régions à télécharger et traiter
REGIONS=("provence-alpes-cote-d-azur" "languedoc-roussillon")  # Ajoute d'autres régions ici si besoin

# Créer le dossier data si ce n'est pas déjà fait
mkdir -p data

# Télécharger les extraits OSM pour chaque région
for REGION in "${REGIONS[@]}"; do
  OSM_FILE="data/${REGION}-latest.osm.pbf"
  if [ ! -f "$OSM_FILE" ]; then
    echo "Téléchargement des données pour $REGION..."
    wget -O "$OSM_FILE" "http://download.geofabrik.de/europe/france/${REGION}-latest.osm.pbf"
  fi
done

# Fusionner les fichiers OSM des régions
if [ ! -f data/combined-latest.osm.pbf ]; then
  echo "Fusion des fichiers OSM pour les régions : ${REGIONS[*]}"
  osmium merge $(for REGION in "${REGIONS[@]}"; do echo -n "data/${REGION}-latest.osm.pbf "; done) -o data/combined-latest.osm.pbf
fi

# Créer le fichier spécifique au profil si non existant
if [ ! -f data/combined-latest-${PROFILE}.osm.pbf ]; then
  echo "Création du fichier spécifique au profil $PROFILE..."
  cp data/combined-latest.osm.pbf data/combined-latest-${PROFILE}.osm.pbf
fi

# Exécuter les étapes de prétraitement avec docker-compose
echo "Exécution du prétraitement avec docker-compose pour le profil $PROFILE..."
PROFILE=${PROFILE} docker-compose -f docker-compose-pretraitement.yml up
