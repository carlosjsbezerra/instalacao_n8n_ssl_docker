#!/bin/bash

# 1. Atualizar o Sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar Docker e Docker Compose
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

# Adicionar chave GPG oficial do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Adicionar repositório Docker
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Instalar Docker
sudo apt update
sudo apt install docker-ce -y

# Verificar instalação do Docker
sudo systemctl status docker

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar instalação do Docker Compose
docker-compose --version

# 3. Configurar Nginx
sudo apt install nginx -y

# 4. Configurar Certbot e Let's Encrypt
sudo apt install certbot python3-certbot-nginx -y

# 5. Configurar Nginx para n8n
sudo bash -c 'cat > /etc/nginx/sites-available/n8n <<EOF
server {
    listen 80;
    server_name seu_domain;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF'

# 6. Remover o Link para o Arquivo Padrão que Não Existe
sudo rm /etc/nginx/sites-enabled/default

# Ativar a configuração do Nginx 
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 7. Obter Certificado SSL com Certbot
sudo certbot --nginx -d seu_domain

# 8. Configurar Docker para n8n
mkdir ~/n8n && cd ~/n8n

# Crie um arquivo docker-compose.yml
cat > docker-compose.yml <<EOF
services:
  n8n:
    image: n8nio/n8n
    restart: always
    ports:
      - "127.0.0.1:5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=<seu_usuario>
      - N8N_BASIC_AUTH_PASSWORD=<sua_senha>
      - N8N_HOST=seu_domain
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
    volumes:
      - ~/.n8n:/home/node/.n8n
EOF

# 9. Iniciar o n8n com Docker
docker-compose up -d

# 10. Verificar Configuração
echo "Acesse https://seu_domain no seu navegador para verificar se o n8n está funcionando corretamente com SSL."

# 11. Automatizar Renovação do Certificado SSL
sudo systemctl status certbot.timer

# Verificar containers Docker
docker-compose ps
