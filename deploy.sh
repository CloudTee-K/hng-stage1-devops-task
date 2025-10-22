#!/bin/bash
# ============================================
# HNG Stage 1 DevOps Automated Deployment Script
# Author: CloudTee-K
# ============================================

set -e
trap 'echo "‚ùå Error occurred on line $LINENO"; exit 1' ERR

LOG_FILE="deployment.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Ì∫Ä Starting automated deployment..."

# ====== 1Ô∏è‚É£ USER INPUTS ======
read -p "Enter your GitHub repository URL: " REPO_URL
read -p "Enter your GitHub Personal Access Token (PAT): " PAT
read -p "Enter SSH username: " SSH_USER
read -p "Enter SSH host/IP: " SSH_HOST
read -p "Enter port number for the app (e.g., 5000): " APP_PORT

# Validate inputs
if [[ -z "$REPO_URL" || -z "$PAT" || -z "$SSH_USER" || -z "$SSH_HOST" || -z "$APP_PORT" ]]; then
  echo "‚ùå One or more inputs are empty. Exiting..."
  exit 1
fi

# ====== 2Ô∏è‚É£ CLONE REPO ======
APP_DIR="hng_app"
if [ -d "$APP_DIR" ]; then
  echo "Ì∑π Removing existing repo directory..."
  rm -rf "$APP_DIR"
fi

echo "Ì≥• Cloning repository..."
git clone "https://${PAT}@${REPO_URL#https://}" "$APP_DIR"
cd "$APP_DIR"

# ====== 3Ô∏è‚É£ SSH CONNECTIVITY ======
echo "Ì¥ó Checking SSH connectivity..."
if ssh -o BatchMode=yes -o ConnectTimeout=5 "$SSH_USER@$SSH_HOST" "echo SSH connected"; then
  echo "‚úÖ SSH connection successful."
else
  echo "‚ùå SSH connection failed."
  exit 1
fi

# ====== 4Ô∏è‚É£ SERVER PREPARATION ======
echo "‚öôÔ∏è  Preparing server environment..."
ssh "$SSH_USER@$SSH_HOST" <<EOF
  set -e
  sudo apt-get update -y
  sudo apt-get install -y docker.io nginx
  sudo usermod -aG docker \$USER
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo systemctl restart nginx
EOF

# ====== 5Ô∏è‚É£ DEPLOY DOCKER APP ======
echo "Ì∞≥ Deploying Docker container..."
scp -r . "$SSH_USER@$SSH_HOST:/home/$SSH_USER/app"
ssh "$SSH_USER@$SSH_HOST" <<EOF
  cd /home/$SSH_USER/app
  sudo docker build -t hng_stage1_app .
  sudo docker stop hng_stage1_app || true
  sudo docker rm hng_stage1_app || true
  sudo docker run -d -p ${APP_PORT}:5000 --name hng_stage1_app hng_stage1_app
EOF

# ====== 6Ô∏è‚É£ NGINX CONFIGURATION ======
echo "Ì∑© Configuring Nginx reverse proxy..."
ssh "$SSH_USER@$SSH_HOST" <<EOF
  sudo bash -c 'cat > /etc/nginx/sites-available/hng_stage1 <<EOL
server {
    listen 80;
    location / {
        proxy_pass http://127.0.0.1:${APP_PORT};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOL'
  sudo ln -sf /etc/nginx/sites-available/hng_stage1 /etc/nginx/sites-enabled/
  sudo nginx -t && sudo systemctl reload nginx
EOF

# ====== 7Ô∏è‚É£ VALIDATION ======
echo "Ì¥ç Validating deployment..."
ssh "$SSH_USER@$SSH_HOST" <<EOF
  sudo docker ps | grep hng_stage1_app && echo "‚úÖ Docker container running."
  sudo systemctl status nginx | grep active && echo "‚úÖ Nginx active."
EOF

# ====== 8Ô∏è‚É£ CLEANUP ======
echo "Ì∑Ω Cleaning up temporary files..."
cd ..
rm -rf "$APP_DIR"

echo "Ìæâ DEPLOYMENT SUCCESSFUL!"
echo "Logs saved in: $LOG_FILE"

