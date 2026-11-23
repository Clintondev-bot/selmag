#!/usr/bin/env bash
# ETAPA 4 - Publicar SELMAG en vm-selmag. Ejecutar dentro de la VM.
# Primera vez:  git clone https://github.com/<tu-usuario>/selmag.git && cd selmag && cp .env.example .env && nano .env
# Siguientes veces: solo ./infra/03-desplegar.sh
set -e
cd "$(dirname "$0")/.."

git pull
docker compose up -d --build
docker compose ps

echo "Prueba de la API:"
sleep 5
curl -s http://localhost/api/health; echo
