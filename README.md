# Tutorial de Configuração do Ambiente com Docker, Nginx e n8n

Este tutorial descreve os passos necessários para configurar um ambiente com Docker, Nginx, Certbot (Let's Encrypt) e n8n. Um script shell está incluído para automatizar a maior parte do processo.

## Script de Automação

Você pode automatizar todos os passos anteriores usando o script shell abaixo. Salve-o como `setup_n8n.sh` e edite para incluir seu domínio, usuário e senha.

### Editar o Script

Antes de executar o script, atualize a linha `server_name seu_domain;` para o seu domínio real, e as linhas:

- N8N_BASIC_AUTH_USER=<seu_usuario>
- N8N_BASIC_AUTH_PASSWORD=<sua_senha>
- N8N_HOST=seu_domain

### Executar o Script
Depois de fazer as edições necessárias, dê permissão de execução e execute o script:


```chmod +x setup_n8n.sh```

```./setup_n8n.sh```

### Script setup_n8n.sh

#!/bin/bash

# 1. Atualizar o Sistema
```sudo apt update && sudo apt upgrade -y```
# 2. Instalar Docker e Docker Compose

```
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce -y
sudo systemctl status docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

# 3. Configurar Nginx
```sudo apt install nginx -y```

# 4. Configurar Certbot e Let's Encrypt
```sudo apt install certbot python3-certbot-nginx -y```

# 5. Configurar Nginx para n8n
```
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
```
# 6. Remover o Link para o Arquivo Padrão que Não Existe
```
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```
# 7. Obter Certificado SSL com Certbot
```sudo certbot --nginx -d seu_domain```

# 8. Configurar Docker para n8n
```mkdir ~/n8n && cd ~/n8n```
```cat > docker-compose.yml <<EOF
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
```
# 9. Iniciar o n8n com Docker
```docker-compose up -d```

# 10. Verificar Configuração
echo "Acesse https://seu_domain no seu navegador para verificar se o n8n está funcionando corretamente com SSL."

# 11. Automatizar Renovação do Certificado SSL
```sudo systemctl status certbot.timer```

# Verificar containers Docker
```docker-compose ps```

# Passos Finais
Edite o Script: Abra o script setup_n8n.sh em um editor de texto e substitua seu_domain pelo seu domínio real. Além disso, substitua <seu_usuario> e <sua_senha> com suas credenciais desejadas.

Dar Permissão de Execução ao Script: No terminal, navegue até o diretório onde o script está salvo e execute o comando abaixo para tornar o script executável:

```chmod +x setup_n8n.sh```

Executar o Script: Execute o script para iniciar a configuração:

```./setup_n8n.sh```

# Verificar a Configuração: Após a execução do script, acesse https://seu_domain no seu navegador para verificar se o n8n está funcionando corretamente com SSL.

Automatizar Renovação do Certificado SSL: Certifique-se de que a renovação automática do Certbot está configurada executando o comando:

```sudo systemctl status certbot.timer```

# Verificar Containers Docker: Verifique os containers Docker em execução com o comando:

```docker-compose ps```
