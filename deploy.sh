#!/usr/bin/env bash
set -e

echo "íº€ Starting automated deployment..."

# Step 1: Build Docker image
echo "í» ï¸ Building Docker image..."
docker build -t simple-web-app .

# Step 2: Remove old container if it exists
if [ "$(docker ps -aq -f name=hng_stage1_container)" ]; then
  echo "í·¹ Removing old container..."
  docker rm -f hng_stage1_container
fi

# Step 3: Run container
echo "í¿ƒ Running container on port 80..."
docker run -d -p 80:5000 --name hng_stage1_container simple-web-app

echo "âœ… Deployment complete! Visit http://localhost"

