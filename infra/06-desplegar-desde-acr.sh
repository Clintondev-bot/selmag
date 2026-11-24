#!/usr/bin/env bash
# Publicar SELMAG usando las imágenes de Azure Container Registry.
# Ejecutar DENTRO de la VM, desde la carpeta selmag:
#   bash infra/06-desplegar-desde-acr.sh            (última versión)
#   TAG=<sha-del-commit> bash infra/06-desplegar-desde-acr.sh   (una versión concreta)
set -e
cd "$(dirname "$0")/.."

set -a; . ./.env; set +a
if [ -z "$ACR_LOGIN_SERVER" ]; then
  echo "Falta ACR_LOGIN_SERVER en .env (ej. ACR_LOGIN_SERVER=selmagacr.azurecr.io)"; exit 1
fi

COMPOSE="docker compose -f docker-compose.yml -f docker-compose.acr.yml"

git pull

# Iniciar sesión en el registro solo la primera vez (pide usuario y contraseña del ACR)
if ! grep -q "$ACR_LOGIN_SERVER" ~/.docker/config.json 2>/dev/null; then
  docker login "$ACR_LOGIN_SERVER"
fi

echo "== Descargando imágenes desde $ACR_LOGIN_SERVER =="
$COMPOSE pull backend frontend

echo "== Levantando contenedores (sin compilar en la VM) =="
$COMPOSE up -d --no-build
$COMPOSE ps

sleep 5
echo "Prueba de la API:"
curl -s http://localhost/api/health; echo
