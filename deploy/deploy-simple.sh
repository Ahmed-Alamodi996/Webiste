#!/bin/bash
# ============================================
# InST Website — Simple Hetzner VPS Deploy
# ============================================
# Uses: Node.js directly + MongoDB in Docker
# No Docker build needed — much faster and lighter.
#
# Usage:
#   chmod +x deploy/deploy-simple.sh
#   sudo ./deploy/deploy-simple.sh your@email.com
# ============================================

set -euo pipefail

EMAIL="${1:?Usage: $0 <email-for-ssl>}"
APP_DIR="$(pwd)"
PRIMARY_DOMAIN="inst-sa.com"

echo ""
echo "============================================"
echo "  InST Website — Simple Deploy"
echo "============================================"
echo ""

# --- Step 1: Install system dependencies ---
echo "[1/6] Installing dependencies..."
apt-get update -qq
apt-get install -y -qq curl gnupg nginx certbot python3-certbot-nginx

# Install Node.js 20
if ! command -v node &> /dev/null || [[ $(node -v | cut -d. -f1 | tr -d v) -lt 20 ]]; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y -qq nodejs
fi
echo "  Node.js $(node -v)"

# Install Docker (for MongoDB only)
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker && systemctl start docker
fi

# Install PM2 (process manager)
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
fi

echo "  All dependencies installed."

# --- Step 2: Start MongoDB in Docker ---
echo "[2/6] Starting MongoDB..."
MONGO_PASS=$(openssl rand -base64 24 | tr -d '=/+' | head -c 32)

docker rm -f inst-mongo 2>/dev/null || true
docker run -d \
    --name inst-mongo \
    --restart unless-stopped \
    -p 127.0.0.1:27017:27017 \
    -v inst_mongo_data:/data/db \
    -e MONGO_INITDB_ROOT_USERNAME=inst_admin \
    -e MONGO_INITDB_ROOT_PASSWORD="$MONGO_PASS" \
    mongo:7

echo "  MongoDB started."

# --- Step 3: Create .env.production ---
echo "[3/6] Setting up environment..."
SECRET=$(openssl rand -hex 32)
ADMIN_PASS=$(openssl rand -base64 16 | tr -d '=/+' | head -c 16)

cat > .env.production << EOF
MONGODB_URI=mongodb://inst_admin:${MONGO_PASS}@127.0.0.1:27017/inst-website?authSource=admin
PAYLOAD_SECRET=${SECRET}
NEXT_PUBLIC_SITE_URL=https://${PRIMARY_DOMAIN}
ADMIN_PASSWORD=${ADMIN_PASS}
NODE_ENV=production
EOF

chmod 600 .env.production

# Also create .env for the build
cp .env.production .env

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║   SAVE THESE CREDENTIALS NOW!        ║"
echo "  ╠══════════════════════════════════════╣"
echo "  ║ Admin Email:    admin@inst.com       ║"
echo "  ║ Admin Password: $ADMIN_PASS"
echo "  ║ Mongo Password: $MONGO_PASS"
echo "  ╚══════════════════════════════════════╝"
echo ""

# --- Step 4: Build the app ---
echo "[4/6] Installing packages and building..."
export NODE_OPTIONS="--max-old-space-size=3072"
npm ci
npm run build
echo "  Build complete."

# --- Step 5: Setup PM2 ---
echo "[5/6] Starting app with PM2..."
pm2 delete inst-website 2>/dev/null || true

# Create PM2 ecosystem file
cat > ecosystem.config.js << 'PMEOF'
module.exports = {
  apps: [{
    name: 'inst-website',
    script: 'node_modules/.bin/next',
    args: 'start',
    cwd: process.env.PWD,
    env: {
      NODE_ENV: 'production',
      PORT: 3000,
    },
    env_file: '.env.production',
    max_memory_restart: '500M',
    instances: 1,
    autorestart: true,
  }]
}
PMEOF

# Load env and start
set -a && source .env.production && set +a
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd -u root --hp /root 2>/dev/null || true

echo "  App running on port 3000."

# --- Step 6: Setup Nginx + SSL ---
echo "[6/6] Configuring Nginx..."

cat > /etc/nginx/sites-available/inst-website << 'NGINXEOF'
# Rate limiting
limit_req_zone $binary_remote_addr zone=general:10m rate=30r/s;
limit_req_zone $binary_remote_addr zone=admin:10m rate=5r/s;
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

server {
    listen 80;
    server_name inst-sa.com www.inst-sa.com inst.sa www.inst.sa;

    location / {
        return 301 https://inst-sa.com$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name inst-sa.com;

    server_tokens off;
    client_max_body_size 20M;

    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;

    # Gzip
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml application/json application/javascript application/xml+rss image/svg+xml;

    # Admin — strict rate limit
    location /admin {
        limit_req zone=admin burst=10 nodelay;
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # API
    location /api {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static assets
    location /_next/static {
        proxy_pass http://127.0.0.1:3000;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }

    # Default
    location / {
        limit_req zone=general burst=50 nodelay;
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Block sensitive files
    location ~ /\. { deny all; return 404; }
    location ~ \.(env|git)$ { deny all; return 404; }
}
NGINXEOF

ln -sf /etc/nginx/sites-available/inst-website /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test nginx config (without SSL first)
# Temporarily make it HTTP-only for certbot
cat > /etc/nginx/sites-available/inst-website-temp << 'TMPEOF'
server {
    listen 80;
    server_name inst-sa.com www.inst-sa.com inst.sa www.inst.sa;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
TMPEOF

ln -sf /etc/nginx/sites-available/inst-website-temp /etc/nginx/sites-enabled/inst-website
nginx -t && systemctl restart nginx

echo "  Getting SSL certificate..."
certbot --nginx -d inst-sa.com -d www.inst-sa.com --email "$EMAIL" --agree-tos --no-eff-email --redirect 2>/dev/null || \
    echo "  SSL for inst-sa.com failed — check DNS."

certbot --nginx -d inst.sa -d www.inst.sa --email "$EMAIL" --agree-tos --no-eff-email --redirect 2>/dev/null || \
    echo "  SSL for inst.sa failed — check DNS."

# Restore full nginx config
ln -sf /etc/nginx/sites-available/inst-website /etc/nginx/sites-enabled/inst-website
rm -f /etc/nginx/sites-available/inst-website-temp
nginx -t && systemctl reload nginx

# Setup firewall
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
fi

echo ""
echo "============================================"
echo "  DEPLOYMENT COMPLETE"
echo "============================================"
echo ""
echo "  Website:  https://$PRIMARY_DOMAIN"
echo "  Admin:    https://$PRIMARY_DOMAIN/admin"
echo ""
echo "  Seed data:  source .env.production && npm run seed"
echo "  View logs:  pm2 logs inst-website"
echo "  Restart:    pm2 restart inst-website"
echo "  Update:"
echo "    git pull && npm ci && npm run build && pm2 restart inst-website"
echo "============================================"
