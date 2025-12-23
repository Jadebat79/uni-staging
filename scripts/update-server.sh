#!/bin/bash
# Server-side update script
# Called by Bitbucket Pipeline via SSM to update services when docker-compose.yml changes

set -e

PROJECT_NAME="${PROJECT_NAME:-staging}"
PROJECT_ROOT="/opt/${PROJECT_NAME}"

echo "Starting server update..."

cd "${PROJECT_ROOT}"

# Pull latest changes from repository
echo "Pulling latest changes from Git..."
git pull origin main

# Check if orchestration files changed
if git diff HEAD@{1} HEAD --name-only | grep -q "orchestration/"; then
  echo "Orchestration files changed, updating services..."
  
  cd orchestration
  
  # Check for new apps that need secrets
  # This is a simple check - if .env file doesn't exist, try to fetch from SSM
  # (More sophisticated logic can be added later)
  
  # Pull latest images
  echo "Pulling latest Docker images..."
  docker compose pull
  
  # Update all services (start new ones, update existing, remove orphaned)
  echo "Updating Docker Compose services..."
  docker compose up -d --remove-orphans
  
  echo "Server update complete!"
else
  echo "No orchestration changes detected, skipping update"
fi

