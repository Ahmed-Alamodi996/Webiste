#!/bin/bash
# ============================================
# InST Website — Hetzner VPS Deployment
# ============================================
# Fully containerized: App + MongoDB + Nginx + SSL
# Nothing installed on the host except Docker.
#
# Usage:
#   chmod +x deploy/deploy.sh
#   sudo ./deploy/deploy.sh your@email.com
#
# Domains: inst-sa.com + inst.sa (configured in nginx)
# ============================================

set -euo pipefail

EMAIL="${1:?Usage: $0 <email-for-ssl>}"
APP_DIR="/opt/inst-website"
PRIMARY_DOMAIN="inst-sa.com"
SECONDARY_DOMAIN="inst.sa"

echo ""
echo "============================================"
echo "  InST Website — Production Deployment"
echo "  Primary:   $PRIMARY_DOMAIN"
echo "  Secondary: $SECONDARY_DOMAIN"
echo "============================================"
echo ""

# --- Step 1: Install Docker ---
if ! command -v docker &> /dev/null; then
    echo "[1/7] Installing Docker..."
    apt-get update -qq
    apt-get install -y -qq ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin
    systemctl enable docker && systemctl start docker
    echo "  Docker installed."
else
    echo "[1/7] Docker already installed."
fi

# --- Step 2: Firewall ---
echo "[2/7] Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    echo "  Firewall: only SSH(22), HTTP(80), HTTPS(443) open."
fi

# --- Step 3: Copy project ---
echo "[3/7] Setting up $APP_DIR..."
mkdir -p "$APP_DIR"

if [ -f "./docker-compose.yml" ]; then
    rsync -av --exclude='node_modules' --exclude='.next' --exclude='bkup' \
        --exclude='.env' --exclude='.env.local' --exclude='.env.production' \
        --exclude='media' --exclude='.git' . "$APP_DIR/"
else
    echo "  ERROR: Run from the project root."
    exit 1
fi

cd "$APP_DIR"

# --- Step 4: Generate secrets ---
echo "[4/7] Setting up environment..."
if [ ! -f ".env.production" ]; then
    SECRET=$(openssl rand -hex 32)
    MONGO_PASS=$(openssl rand -base64 24 | tr -d '=/+' | head -c 32)
    ADMIN_PASS=$(openssl rand -base64 16 | tr -d '=/+' | head -c 16)

    cat > .env.production << EOF
SITE_URL=https://$PRIMARY_DOMAIN
MONGO_USER=inst_admin
MONGO_PASSWORD=$MONGO_PASS
PAYLOAD_SECRET=$SECRET
ADMIN_PASSWORD=$ADMIN_PASS
EOF
    chmod 600 .env.production

    echo ""
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║   SAVE THESE CREDENTIALS NOW!        ║"
    echo "  ╠══════════════════════════════════════╣"
    echo "  ║ Admin Email:    admin@inst.com        ║"
    echo "  ║ Admin Password: $ADMIN_PASS"
    echo "  ║ Mongo Password: $MONGO_PASS"
    echo "  ╚══════════════════════════════════════╝"
    echo ""
else
    echo "  .env.production exists. Keeping existing."
fi

# --- Step 5: Start with HTTP only (for SSL cert) ---
echo "[5/7] Starting services (HTTP mode)..."

# Create temporary compose that uses initial nginx config
sed "s|./deploy/nginx-docker.conf|./deploy/nginx-initial.conf|g" docker-compose.yml > docker-compose.init.yml

docker compose -f docker-compose.init.yml --env-file .env.production down 2>/dev/null || true
docker compose -f docker-compose.init.yml --env-file .env.production up -d --build

echo "  Waiting for app to start..."
sleep 20

# --- Step 6: Get SSL certificates ---
echo "[6/7] Obtaining SSL certificates..."

# Primary domain
echo "  Getting cert for $PRIMARY_DOMAIN..."
docker compose -f docker-compose.init.yml --env-file .env.production run --rm certbot \
    certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email "$EMAIL" --agree-tos --no-eff-email \
    -d "$PRIMARY_DOMAIN" -d "www.$PRIMARY_DOMAIN" && \
    echo "  SSL for $PRIMARY_DOMAIN obtained." || \
    echo "  WARNING: SSL for $PRIMARY_DOMAIN failed. Check DNS."

# Secondary domain
echo "  Getting cert for $SECONDARY_DOMAIN..."
docker compose -f docker-compose.init.yml --env-file .env.production run --rm certbot \
    certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email "$EMAIL" --agree-tos --no-eff-email \
    -d "$SECONDARY_DOMAIN" -d "www.$SECONDARY_DOMAIN" && \
    echo "  SSL for $SECONDARY_DOMAIN obtained." || \
    echo "  WARNING: SSL for $SECONDARY_DOMAIN failed. Check DNS."

# --- Step 7: Switch to HTTPS ---
echo "[7/7] Switching to HTTPS mode..."
docker compose -f docker-compose.init.yml --env-file .env.production down
rm -f docker-compose.init.yml

docker compose --env-file .env.production up -d --build

# --- Seed database ---
echo ""
echo "Seeding database..."
sleep 10
source .env.production
docker compose --env-file .env.production exec -e MONGODB_URI="mongodb://${MONGO_USER}:${MONGO_PASSWORD}@mongo:27017/inst-website?authSource=admin" \
    -e PAYLOAD_SECRET="$PAYLOAD_SECRET" -e ADMIN_PASSWORD="$ADMIN_PASS" \
    app sh -c "node -e \"
const { execSync } = require('child_process');
console.log('Seeding will be done via admin panel or manual seed.');
\"" 2>/dev/null || echo "  Seed via admin panel at https://$PRIMARY_DOMAIN/admin"

echo ""
echo "============================================"
echo "  DEPLOYMENT COMPLETE"
echo "============================================"
echo ""
echo "  Website:     https://$PRIMARY_DOMAIN"
echo "  Alt domain:  https://$SECONDARY_DOMAIN (redirects)"
echo "  Admin panel: https://$PRIMARY_DOMAIN/admin"
echo ""
echo "  Commands:"
echo "    View logs:    cd $APP_DIR && docker compose --env-file .env.production logs -f"
echo "    Restart:      cd $APP_DIR && docker compose --env-file .env.production restart"
echo "    Update site:  cd $APP_DIR && git pull && docker compose --env-file .env.production up -d --build"
echo "    Stop:         cd $APP_DIR && docker compose --env-file .env.production down"
echo ""
echo "  SSL auto-renews via certbot container."
echo "============================================"
