# Utiliser l'image de base OSRM backend
FROM osrm/osrm-backend:latest

# Définir le profil comme variable d'environnement
ARG PROFILE
ENV PROFILE=${PROFILE}

# Définir le répertoire de travail
WORKDIR /data

# Exposer le port utilisé par osrm-routed
EXPOSE 5000