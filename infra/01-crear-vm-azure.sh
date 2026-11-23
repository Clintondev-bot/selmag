#!/usr/bin/env bash
# ETAPA 2 - Crear el servidor vm-selmag en Azure (ejecutar en Azure Cloud Shell o con Azure CLI)
# Si ya creaste la VM desde el portal, salta este script y revisa que los
# valores coincidan con el diagrama de despliegue.
set -e

GRUPO=rg-selmag
REGION=eastus
VM=vm-selmag
USUARIO=azureuser

az group create --name $GRUPO --location $REGION

# Ubuntu Server 22.04 LTS, 2 vCPU, 4 GiB RAM (Standard_B2s), disco de 30 GiB
az vm create \
  --resource-group $GRUPO \
  --name $VM \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --os-disk-size-gb 30 \
  --admin-username $USUARIO \
  --generate-ssh-keys \
  --public-ip-sku Standard \
  --public-ip-address-allocation static

# Reglas del grupo de seguridad (NSG): SSH 22 ya queda abierto al crear la VM.
# Se abre HTTP 80. PostgreSQL (5432) y la API (3000) NO se abren a Internet.
az vm open-port --resource-group $GRUPO --name $VM --port 80 --priority 1010

# Mostrar la IP pública para el diagrama y para conectarse por SSH
az vm show -d -g $GRUPO -n $VM --query "{IP:publicIps, Tamano:hardwareProfile.vmSize, Region:location}" -o table
