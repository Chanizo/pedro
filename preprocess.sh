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

##### NE MARCHE PAS avec Docker :( => à creuser ?
# osrm-extract n'accepte pas d'option pour spécifier le nom du fichier d'output
# on utilise donc des liens symboliques pour tricher sur le nom du fichier en entrée sur lequel sera basé le nom en sortie
# ln -s data/provence-alpes-cote-d-azur-latest.osm.pbf data/provence-alpes-cote-d-azur-latest-${PROFILE}.osm.pbf

# Exécuter les étapes de prétraitement avec docker-compose
PROFILE=${PROFILE} docker-compose -f docker-compose-pretraitement.yml up
