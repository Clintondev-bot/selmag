#!/usr/bin/env bash
# Detener Kubernetes (k3s) y volver a publicar SELMAG con Docker Compose.
# Ejecutar DENTRO de la VM: bash infra/05-volver-a-compose.sh
set -e
cd "$(dirname "$0")/.."

echo "== Eliminando los recursos de SELMAG en Kubernetes =="
if command -v k3s >/dev/null 2>&1; then
  kubectl delete namespace selmag --ignore-not-found
  sudo systemctl disable --now k3s
  # k3s-killall.sh detiene los contenedores del clúster y libera el puerto 80
  sudo /usr/local/bin/k3s-killall.sh >/dev/null 2>&1 || true
fi

echo "== Levantando Docker Compose =="
docker compose up -d
docker compose ps
sleep 5
curl -s http://localhost/api/health; echo
