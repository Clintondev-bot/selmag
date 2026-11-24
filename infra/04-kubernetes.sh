#!/usr/bin/env bash
# Desplegar SELMAG en Kubernetes (k3s) dentro de vm-selmag.
# Ejecutar DENTRO de la VM, desde la carpeta selmag:  bash infra/04-kubernetes.sh
# Para volver a Docker Compose:                        bash infra/05-volver-a-compose.sh
set -e
cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo "Falta el archivo .env (cp .env.example .env y pon la contraseña)"; exit 1
fi
set -a; . ./.env; set +a

echo "== 1. Actualizar código y construir imágenes =="
git pull
docker compose build

echo "== 2. Detener Docker Compose (libera el puerto 80) =="
docker compose down

echo "== 3. Instalar k3s (Kubernetes liviano) usando Docker como runtime =="
if ! command -v k3s >/dev/null 2>&1; then
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--docker --disable traefik --write-kubeconfig-mode 644" sh -
else
  sudo systemctl enable --now k3s
fi
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
echo "Esperando a que el nodo esté listo..."
until kubectl get nodes 2>/dev/null | grep -q " Ready"; do sleep 3; done
kubectl get nodes

echo "== 4. Crear namespace, Secret y ConfigMap =="
kubectl apply -f k8s/00-namespace.yaml
kubectl -n selmag create secret generic selmag-db \
  --from-literal=POSTGRES_DB="$POSTGRES_DB" \
  --from-literal=POSTGRES_USER="$POSTGRES_USER" \
  --from-literal=POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl -n selmag create configmap selmag-initdb \
  --from-file=01-init.sql=database/init.sql \
  --dry-run=client -o yaml | kubectl apply -f -

echo "== 5. Desplegar las 3 capas =="
kubectl apply -f k8s/
kubectl -n selmag rollout restart deployment/backend deployment/frontend >/dev/null
for d in db backend frontend; do
  kubectl -n selmag rollout status deployment/$d --timeout=300s
done

echo "== 6. Estado del clúster =="
kubectl -n selmag get pods,svc -o wide
sleep 3
echo "Prueba de la API:"
curl -s http://localhost/api/health; echo
