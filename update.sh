#!/bin/bash

# Solicitar el nuevo hostname al usuario ANTES de usar sudo
read -p "🖥️ ¿Cuál quieres que sea el nuevo nombre de host? " nuevo_hostname

if [ -z "$nuevo_hostname" ]; then
    echo "❌ No se especificó un nuevo hostname. No se realizaron cambios."
    exit 1
fi

# Actualizar el sistema
echo "🔄 Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Cambiar el hostname
echo "✅ Cambiando el hostname a: $nuevo_hostname"
echo "$nuevo_hostname" | sudo tee /etc/hostname
sudo hostnamectl set-hostname "$nuevo_hostname"

# Actualizar /etc/hosts
sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$nuevo_hostname/" /etc/hosts

# Mensaje final
echo "✅ Hostname actualizado. Se recomienda reiniciar la máquina para aplicar los cambios."
read -p "🔁 ¿Quieres reiniciar ahora? (s/n): " reiniciar

if [[ "$reiniciar" =~ ^[sS]$ ]]; then
    sudo reboot
else
    echo "👌 Puedes reiniciar más tarde para completar los cambios."
fi
