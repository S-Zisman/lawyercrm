#!/bin/bash

# ==========================================
# Deploy LawyerCRM to VPS
# ==========================================

echo "🚀 Deploying LawyerCRM to VPS..."

# Change to project directory
cd "/Users/mymac/TRAINING/ВАЙБКОДИНГ (ДАМИР ХАЛИЛОВ)/MY PROJECTS/lawyercrm"

# Create tarball
echo "📦 Creating archive..."
tar -czf lawyercrm.tar.gz \
  auth.html \
  index.html \
  dashboard.html \
  auth.js \
  dashboard.js \
  config.js \
  styles.css \
  db-config.php \
  db-config.local.example.php \
  init-db.php \
  create-user.php \
  api/ \
  sql-schemas/ \
  assets/

# Upload to VPS
echo "📤 Uploading to VPS..."
sshpass -p 'CanadaChili2025$end' scp \
  -o StrictHostKeyChecking=no \
  lawyercrm.tar.gz \
  root@46.101.162.160:/var/www/html/

# Extract on VPS
echo "📂 Extracting files on VPS..."
sshpass -p 'CanadaChili2025$end' ssh \
  -o StrictHostKeyChecking=no \
  root@46.101.162.160 \
  "cd /var/www/html && \
   rm -rf lawyercrm && \
   mkdir -p lawyercrm && \
   tar -xzf lawyercrm.tar.gz -C lawyercrm/ && \
   rm lawyercrm.tar.gz && \
   chmod -R 755 lawyercrm/"

# Cleanup local tarball
rm lawyercrm.tar.gz

echo "✅ LawyerCRM deployed successfully!"
echo ""
echo "🌐 Access the application at:"
echo "   http://46.101.162.160/lawyercrm/auth.html"
echo ""
echo "📝 Next steps:"
echo "   1. SSH into VPS and run: cd /var/www/html/lawyercrm && php init-db.php"
echo "   2. Create first user: php create-user.php"
echo ""
