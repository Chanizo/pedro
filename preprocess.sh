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
REGIONS=("provence-alpes-cote-d-azur" "languedoc-roussillon")  # Ajoute d'autres régions ici

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

  # Exécuter les étapes de prétraitement avec docker-compose
  REGION=${REGION} PROFILE=${PROFILE} docker-compose -f docker-compose-pretraitement.yml up
done
