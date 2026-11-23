#!/usr/bin/env bash
# ETAPA 2 - Configurar el servidor: ejecutar DENTRO de vm-selmag (por SSH)
set -e

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y git ca-certificates curl

# Docker Engine + plugin Docker Compose (script oficial de Docker)
curl -fsSL https://get.docker.com | sudo sh

# Permitir usar docker sin sudo (cerrar y volver a abrir la sesión SSH después)
sudo usermod -aG docker $USER

# Iniciar Docker con el sistema
sudo systemctl enable --now docker

# Zona horaria de Lima
sudo timedatectl set-timezone America/Lima

docker --version
docker compose version
echo "Listo. Sal de la sesión (exit) y vuelve a entrar por SSH."
