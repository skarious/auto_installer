#!/bin/bash

# Actualización del sistema
echo "🔄 Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Cambiar el hostname
read -p "🖥️ ¿Cuál quieres que sea el nuevo nombre de host? " nuevo_hostname

if [ -n "$nuevo_hostname" ]; then
    echo "✅ Cambiando el hostname a: $nuevo_hostname"
    echo "$nuevo_hostname" | sudo tee /etc/hostname
    sudo hostnamectl set-hostname "$nuevo_hostname"

    # Actualiza /etc/hosts (reemplaza la línea con el hostname antiguo)
    sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$nuevo_hostname/" /etc/hosts

    echo "🔁 Es recomendable reiniciar la máquina para aplicar los cambios completamente."
else
    echo "❌ No se especificó un nuevo hostname. No se realizaron cambios."
fi
