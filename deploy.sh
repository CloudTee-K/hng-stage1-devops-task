#!/bin/bash
# HNG Stage 1 DevOps Task - Automated Deployment Script
# Author: CloudTee-K
# Version: 1.0

set -euo pipefail
LOG_FILE="deployment.log"

echo "=== Starting Automated Deployment ($(date)) ===" | tee -a "$LOG_FILE"

# ---------- CONFIGURATION ----------
SSH_USER="ubuntu"
SSH_HOST="127.0.0.1"
SSH_PORT=22
REPO_URL="https://github.com/CloudTee-K/hng-stage1-devops-task.git"
APP_NAME="simple-web-app"
CONTAINER_NAME="hng_stage1_container"
DOCKER_IMAGE="simple-web-app:latest"
NGINX_CONF="/etc/nginx/sites-available/${APP_NAME}"

# ---------- HELPER FUNCTIONS ----------
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

cleanup() {
  log "í·¹ Cleaning up previous deployments..."
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# ---------- VALIDATION ----------
log "í´ Checking prerequisites..."
if ! command -v docker >/dev/null 2>&1; then
  log "Docker not installed. Installing..."
  sudo apt-get update -y && sudo apt-get install -y docker.io
  sudo systemctl start docker
  sudo systemctl enable docker
else
  log "âœ… Docker is installed: $(docker --version)"
fi

if ! command -v nginx >/dev/null 2>&1; then
  log "Installing Nginx..."
  sudo apt-get install -y nginx
  sudo systemctl start nginx
  sudo systemctl enable nginx
else
  log "âœ… Nginx is installed."
fi

# ---------- GIT OPERATIONS ----------
log "í³¦ Cloning repository..."
rm -rf app || true
git clone "$REPO_URL" app || { log "âŒ Failed to clone repo."; exit 1; }
cd app

# ---------- DOCKER BUILD ----------
log "âš™ï¸ Building Docker image..."
docker build -t "$DOCKER_IMAGE" . | tee -a "$LOG_FILE"

# ---------- RUN CONTAINER ----------
log "íº€ Running Docker container..."
docker run -d -p 80:5000 --name "$CONTAINER_NAME" "$DOCKER_IMAGE"

# ---------- NGINX CONFIGURATION ----------
log "í·© Configuring Nginx reverse proxy..."
sudo bash -c "cat > $NGINX_CONF" <<EOF
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
log "âœ… Nginx configured and reloaded."

# ---------- DEPLOYMENT VALIDATION ----------
log "í·  Validating deployment..."
if docker ps | grep -q "$CONTAINER_NAME"; then
  log "âœ… Container '$CONTAINER_NAME' is running."
else
  log "âŒ Container failed to start."
  exit 1
fi

if curl -s http://127.0.0.1 | grep -qi "html"; then
  log "âœ… App responded successfully on port 80."
else
  log "âš ï¸ App may not be responding correctly."
fi

log "í¾¯ Deployment successful!"
echo "âœ… Deployment complete! Visit http://localhost" | tee -a "$LOG_FILE"
#!/bin/bash
# HNG Stage 1 DevOps Task - Automated Deployment Script
# Author: CloudTee-K
# Version: 1.0

set -euo pipefail
LOG_FILE="deployment.log"

echo "=== Starting Automated Deployment ($(date)) ===" | tee -a "$LOG_FILE"

# ---------- CONFIGURATION ----------
SSH_USER="ubuntu"
SSH_HOST="127.0.0.1"
SSH_PORT=22
REPO_URL="https://github.com/CloudTee-K/hng-stage1-devops-task.git"
APP_NAME="simple-web-app"
CONTAINER_NAME="hng_stage1_container"
DOCKER_IMAGE="simple-web-app:latest"
NGINX_CONF="/etc/nginx/sites-available/${APP_NAME}"

# ---------- HELPER FUNCTIONS ----------
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

cleanup() {
  log "í·¹ Cleaning up previous deployments..."
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# ---------- VALIDATION ----------
log "í´ Checking prerequisites..."
if ! command -v docker >/dev/null 2>&1; then
  log "Docker not installed. Installing..."
  sudo apt-get update -y && sudo apt-get install -y docker.io
  sudo systemctl start docker
  sudo systemctl enable docker
else
  log "âœ… Docker is installed: $(docker --version)"
fi

if ! command -v nginx >/dev/null 2>&1; then
  log "Installing Nginx..."
  sudo apt-get install -y nginx
  sudo systemctl start nginx
  sudo systemctl enable nginx
else
  log "âœ… Nginx is installed."
fi

# ---------- GIT OPERATIONS ----------
log "í³¦ Cloning repository..."
rm -rf app || true
git clone "$REPO_URL" app || { log "âŒ Failed to clone repo."; exit 1; }
cd app

# ---------- DOCKER BUILD ----------
log "âš™ï¸ Building Docker image..."
docker build -t "$DOCKER_IMAGE" . | tee -a "$LOG_FILE"

# ---------- RUN CONTAINER ----------
log "íº€ Running Docker container..."
docker run -d -p 80:5000 --name "$CONTAINER_NAME" "$DOCKER_IMAGE"

# ---------- NGINX CONFIGURATION ----------
log "í·© Configuring Nginx reverse proxy..."
sudo bash -c "cat > $NGINX_CONF" <<EOF
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
log "âœ… Nginx configured and reloaded."

# ---------- DEPLOYMENT VALIDATION ----------
log "í·  Validating deployment..."
if docker ps | grep -q "$CONTAINER_NAME"; then
  log "âœ… Container '$CONTAINER_NAME' is running."
else
  log "âŒ Container failed to start."
  exit 1
fi

if curl -s http://127.0.0.1 | grep -qi "html"; then
  log "âœ… App responded successfully on port 80."
else
  log "âš ï¸ App may not be responding correctly."
fi

log "í¾¯ Deployment successful!"
echo "âœ… Deployment complete! Visit http://localhost" | tee -a "$LOG_FILE"

