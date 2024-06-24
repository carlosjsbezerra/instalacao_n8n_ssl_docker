# Tutorial de Configuração do Ambiente com Docker, Nginx e n8n

Este tutorial descreve os passos necessários para configurar um ambiente com Docker, Nginx, Certbot (Let's Encrypt) e n8n. Um script shell está incluído para automatizar a maior parte do processo.

## Pré-requisitos

- Sistema operacional: Ubuntu 20.04 ou superior
- Acesso root ou privilégio `sudo`
- Um domínio válido apontando para o servidor

## Passos para Configuração

### 1. Atualizar o Sistema

Primeiro, atualize o sistema operacional para garantir que todos os pacotes estão nas versões mais recentes.

```sh
sudo apt update && sudo apt upgrade -y

### 2. Instalar Docker e Docker Compose

Instale as dependências necessárias e adicione o repositório Docker:

sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce -y

Verifique a instalação do Docker:

sudo systemctl status docke

Instale o Docker Compose:

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
