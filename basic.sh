#!/bin/bash
set -e

# Remover posibles caracteres BOM o CRLF
sed -i $'1s/^\xEF\xBB\xBF//' "$0"
dos2unix "$0" 2>/dev/null || true

# Recibe los parámetros de la línea de comando
traefik="$1"
portainer="$2"
email="$3"

# Verifica si todos los parámetros fueron proporcionados
if [ -z "$traefik" ] || [ -z "$portainer" ] || [ -z "$email" ]; then
    echo "Error: Todos los parámetros son obligatorios"
    echo "Uso: $0 <traefik_domain> <portainer_domain> <email>"
    exit 1
fi

# Generar claves y credenciales
key=$(openssl rand -hex 16)
traefik_user="admin"
traefik_pass="admin"

# Instalar Docker si no está instalado
install_docker() {
    echo "🔍 Verificando instalación de Docker..."
    if ! command -v docker &> /dev/null; then
        echo "📦 Instalando Docker..."
        # Remover versiones antiguas
        apt-get remove -y docker docker-engine docker.io containerd runc || true
        
        # Instalar dependencias
        apt-get update
        apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            lsb-release

        # Añadir clave GPG oficial de Docker
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        # Configurar repositorio
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Instalar Docker Engine
        apt-get update
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
        # Instalar Docker Compose
        curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        
        echo "✅ Docker instalado con éxito!"
    else
        echo "✅ Docker ya está instalado!"
    fi
}

# Instalar Docker
install_docker

# Generar contraseña htpasswd
generate_htpasswd() {
    local username=$1
    local password=$2
    
    # Instalar apache2-utils si no está instalado
    if ! command -v htpasswd &> /dev/null; then
        apt-get update > /dev/null 2>&1
        apt-get install -y apache2-utils > /dev/null 2>&1
    fi
    
    # Crear archivo temporal y generar hash
    local temp_file=$(mktemp)
    htpasswd -nb -B "$username" "$password" > "$temp_file"
    local hash=$(cat "$temp_file")
    rm "$temp_file"
    
    # Duplicar los caracteres $ en el hash
    hash=$(echo "$hash" | sed 's/\$/\$\$/g')
    echo "$hash"
}

htpasswd=$(generate_htpasswd "$traefik_user" "$traefik_pass")

# Crear directorio de trabajo
mkdir -p ~/Portainer
cd ~/Portainer

# Crear docker-compose.yml
cat >docker-compose.yml <<EOL
services:
  traefik:
    container_name: traefik
    image: "traefik:latest"
    restart: always
    command:
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --api.insecure=true
      - --api.dashboard=true
      - --providers.docker
      - --log.level=ERROR
      - --certificatesresolvers.leresolver.acme.httpchallenge=true
      - --certificatesresolvers.leresolver.acme.email=$email
      - --certificatesresolvers.leresolver.acme.storage=./acme.json
      - --certificatesresolvers.leresolver.acme.httpchallenge.entrypoint=web
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "./acme.json:/acme.json"
    labels:
      - "traefik.http.routers.http-catchall.rule=hostregexp(\`{host:.+}\`)"
      - "traefik.http.routers.http-catchall.entrypoints=web"
      - "traefik.http.routers.http-catchall.middlewares=redirect-to-https"
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
      - "traefik.http.routers.traefik-dashboard.rule=Host(\`$traefik\`)"
      - "traefik.http.routers.traefik-dashboard.entrypoints=websecure"
      - "traefik.http.routers.traefik-dashboard.service=api@internal"
      - "traefik.http.routers.traefik-dashboard.tls.certresolver=leresolver"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=$htpasswd"
      - "traefik.http.routers.traefik-dashboard.middlewares=traefik-auth"
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    command: -H unix:///var/run/docker.sock
    restart: always
    environment:
      - ADMIN_USERNAME=$email
      - ADMIN_PASSWORD=$key
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend.rule=Host(\`$portainer\`)"
      - "traefik.http.routers.frontend.entrypoints=websecure"
      - "traefik.http.services.frontend.loadbalancer.server.port=9000"
      - "traefik.http.routers.frontend.service=frontend"
      - "traefik.http.routers.frontend.tls.certresolver=leresolver"
volumes:
  portainer_data:
EOL

# Configurar certificados SSL
touch acme.json
chmod 600 acme.json

# Iniciar contenedores
docker compose up -d

# Aguardar Portainer inicializar
echo "Agurdando Portainer inicializar..."
sleep 10

# Inicializar cuenta de administrador
PORTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' portainer)
PORTAINER_URL="http://$PORTAINER_IP:9000"
curl -s -X POST "$PORTAINER_URL/api/users/admin/init" \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"$email\", \"password\": \"$key\"}"

# Mostrar mensaje de conclusión
clear
echo "🎉 ¡Instalación concluida con éxito! 🎉"
echo ""
echo "🔑 ==== Credenciales de Portainer ==== 🔑"
echo "🌐 URL de Portainer: https://$portainer"
echo "👤 Usuario de Portainer: $email"
echo "🔐 Contraseña de Portainer: $key"
echo ""
echo "🔑 ==== Credenciales de Traefik ==== 🔑"
echo "🌐 URL de Traefik: https://$traefik"
echo "👤 Usuario de Traefik: $traefik_user"
echo "🔐 Contraseña de Traefik: $traefik_pass"
echo ""
echo "🌍 Visite el sitio: https://packtypebot.com.br"
echo "🚀 ¡Su instalación está completa y lista para usar! 🚀"
