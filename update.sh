#!/bin/bash

VERDE="\033[0;32m"
RESET="\033[0m"

# Tomar el hostname del primer argumento
nuevo_hostname="$1"

if [ -z "$nuevo_hostname" ]; then
    echo -e "${VERDE}❌ Debes pasar el nuevo hostname como argumento:${RESET}"
    echo -e "${VERDE}   Ejemplo: curl -sSL bit.ly/update_vm | bash -s nuevo-host${RESET}"
    exit 1
fi

echo -e "${VERDE}🔄 Actualizando el sistema...${RESET}"
sudo apt update && sudo apt upgrade -y

echo -e "${VERDE}✅ Cambiando hostname a: $nuevo_hostname${RESET}"
echo "$nuevo_hostname" | sudo tee /etc/hostname
sudo hostnamectl set-hostname "$nuevo_hostname"
sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$nuevo_hostname/" /etc/hosts

echo -e "${VERDE}✅ Hostname actualizado. Puedes reiniciar para aplicar los cambios.${RESET}"
