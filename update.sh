#!/bin/bash

# Color verde
VERDE="\033[0;32m"
RESET="\033[0m"

# Solicitar el nuevo hostname al usuario ANTES de usar sudo
echo -e "${VERDE}🖥️ ¿Cuál quieres que sea el nuevo nombre de host?${RESET}"
read -p "> " nuevo_hostname

if [ -z "$nuevo_hostname" ]; then
    echo -e "${VERDE}❌ No se especificó un nuevo hostname. No se realizaron cambios.${RESET}"
    exit 1
fi

# Actualizar el sistema
echo -e "${VERDE}🔄 Actualizando el sistema...${RESET}"
sudo apt update && sudo apt upgrade -y

# Cambiar el hostname
echo -e "${VERDE}✅ Cambiando el hostname a: $nuevo_hostname${RESET}"
echo "$nuevo_hostname" | sudo tee /etc/hostname
sudo hostnamectl set-hostname "$nuevo_hostname"

# Actualizar /etc/hosts
sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$nuevo_hostname/" /etc/hosts

# Mensaje final
echo -e "${VERDE}✅ Hostname actualizado. Se recomienda reiniciar la máquina para aplicar los cambios.${RESET}"
echo -e "${VERDE}🔁 ¿Quieres reiniciar ahora? (s/n):${RESET}"
read -p "> " reiniciar

if [[ "$reiniciar" =~ ^[sS]$ ]]; then
    sudo reboot
else
    echo -e "${VERDE}👌 Puedes reiniciar más tarde para completar los cambios.${RESET}"
fi
