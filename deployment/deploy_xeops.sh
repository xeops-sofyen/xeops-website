#!/bin/bash

# =============================================================================
# XeOps.ai Deployment Script
# Automated deployment to Hostinger WordPress hosting
# =============================================================================

set -e  # Exit on any error

# Configuration
REMOTE_HOST="82.25.113.15"
REMOTE_USER="u383093123"
REMOTE_PASSWORD="xPw@61gqT92vWuLgC9hu"
REMOTE_PATH="/domains/xeops.ai/public_html"
LOCAL_PATH="/Users/sofyenmarzougui/Desktop/xeops_local_development"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$LOCAL_PATH/backups/$BACKUP_DATE"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Banner
echo "
========================================
    XeOps.ai Deployment Script
========================================
"

# Create backup directory
log "Creating backup directory..."
mkdir -p "$BACKUP_DIR"
success "Backup directory created: $BACKUP_DIR"

# 1. Local Backup
log "Step 1: Creating local backup of current development..."

# Copy all XeOps files to backup
cp "$LOCAL_PATH/xeops_final_site.html" "$BACKUP_DIR/"
cp "$LOCAL_PATH/compliance.html" "$BACKUP_DIR/"
cp "$LOCAL_PATH/blog.html" "$BACKUP_DIR/"
cp "$LOCAL_PATH/free-scan-form.html" "$BACKUP_DIR/"
cp "$LOCAL_PATH/form-handler.js" "$BACKUP_DIR/"
cp "$LOCAL_PATH/form-submit.php" "$BACKUP_DIR/"

# Create deployment manifest
cat > "$BACKUP_DIR/deployment_manifest.txt" << EOF
XeOps.ai Deployment Manifest
Generated: $(date)
Backup Location: $BACKUP_DIR

Files included:
- xeops_final_site.html (Main website)
- compliance.html (European compliance page)
- blog.html (Blog page)
- free-scan-form.html (Contact form)
- form-handler.js (Form JavaScript)
- form-submit.php (Form backend)

Deployment Target:
- Host: $REMOTE_HOST
- Path: $REMOTE_PATH
- User: $REMOTE_USER
EOF

success "Local backup completed"

# 2. Remote Backup
log "Step 2: Creating remote backup..."

# Create remote backup directory
ssh "$REMOTE_USER@$REMOTE_HOST" "mkdir -p /tmp/xeops_backup_$BACKUP_DATE"

# Backup current remote files
ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_PATH && cp index.html /tmp/xeops_backup_$BACKUP_DATE/ 2>/dev/null || echo 'No index.html to backup'"
ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_PATH && cp compliance.html /tmp/xeops_backup_$BACKUP_DATE/ 2>/dev/null || echo 'No compliance.html to backup'"
ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_PATH && cp blog.html /tmp/xeops_backup_$BACKUP_DATE/ 2>/dev/null || echo 'No blog.html to backup'"

success "Remote backup completed"

# 3. Pre-deployment checks
log "Step 3: Running pre-deployment checks..."

# Check if files exist locally
for file in "xeops_final_site.html" "compliance.html" "blog.html" "free-scan-form.html" "form-handler.js" "form-submit.php"; do
    if [[ ! -f "$LOCAL_PATH/$file" ]]; then
        error "Local file missing: $file"
    fi
done

# Check remote connectivity
if ! ssh -q "$REMOTE_USER@$REMOTE_HOST" exit; then
    error "Cannot connect to remote server"
fi

success "Pre-deployment checks passed"

# 4. Deploy files
log "Step 4: Deploying files to remote server..."

# Deploy main website as index.html
log "Deploying main website..."
scp "$LOCAL_PATH/xeops_final_site.html" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/index.html"

# Deploy other pages
log "Deploying additional pages..."
scp "$LOCAL_PATH/compliance.html" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/"
scp "$LOCAL_PATH/blog.html" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/"
scp "$LOCAL_PATH/free-scan-form.html" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/"

# Deploy JavaScript and PHP files
log "Deploying form handlers..."
scp "$LOCAL_PATH/form-handler.js" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/"
scp "$LOCAL_PATH/form-submit.php" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/"

# Create necessary directories on remote
ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_PATH && mkdir -p scan_requests logs"

success "Files deployed successfully"

# 5. Set permissions
log "Step 5: Setting file permissions..."

ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_PATH && chmod 644 *.html *.js && chmod 755 *.php && chmod 755 scan_requests logs"

success "Permissions set"

# 6. Verify deployment
log "Step 6: Verifying deployment..."

# Check if files exist on remote
REMOTE_FILES=("index.html" "compliance.html" "blog.html" "free-scan-form.html" "form-handler.js" "form-submit.php")

for file in "${REMOTE_FILES[@]}"; do
    if ssh "$REMOTE_USER@$REMOTE_HOST" "test -f $REMOTE_PATH/$file"; then
        success "Verified: $file"
    else
        warning "Missing: $file"
    fi
done

# 7. Test website
log "Step 7: Testing website accessibility..."

if curl -s -o /dev/null -w "%{http_code}" "https://xeops.ai" | grep -q "200"; then
    success "Website is accessible at https://xeops.ai"
else
    warning "Website accessibility test failed - please check manually"
fi

# 8. WordPress integration (optional)
log "Step 8: WordPress integration options..."

cat << EOF

${YELLOW}WordPress Integration Options:${NC}

1. ${BLUE}Replace WordPress entirely:${NC}
   - Your static HTML files are now the main site
   - WordPress admin remains accessible at /wp-admin

2. ${BLUE}Hybrid approach:${NC}
   - Static pages for main content
   - WordPress for blog/admin functionality
   - Create custom WordPress theme later

3. ${BLUE}WordPress theme conversion:${NC}
   - Convert HTML to WordPress theme
   - Preserve WordPress functionality
   - More complex integration

Current deployment uses option 1 (static replacement).

EOF

# 9. Create rollback script
log "Step 9: Creating rollback script..."

cat > "$BACKUP_DIR/rollback.sh" << 'EOF'
#!/bin/bash

# Rollback script for XeOps.ai deployment
# Usage: ./rollback.sh

REMOTE_HOST="82.25.113.15"
REMOTE_USER="u383093123"
REMOTE_PATH="/domains/xeops.ai/public_html"
BACKUP_DATE="BACKUP_DATE_PLACEHOLDER"

echo "Rolling back XeOps.ai deployment..."

# Restore from backup
ssh "$REMOTE_USER@$REMOTE_HOST" "cd /tmp/xeops_backup_$BACKUP_DATE && cp * $REMOTE_PATH/ 2>/dev/null || echo 'Some files may not exist'"

echo "Rollback completed. Please verify manually."
EOF

# Replace placeholder with actual backup date
sed -i '' "s/BACKUP_DATE_PLACEHOLDER/$BACKUP_DATE/g" "$BACKUP_DIR/rollback.sh"
chmod +x "$BACKUP_DIR/rollback.sh"

success "Rollback script created: $BACKUP_DIR/rollback.sh"

# 10. Final report
log "Step 10: Deployment completed!"

cat << EOF

${GREEN}🎉 Deployment Summary:${NC}

${BLUE}Deployed Files:${NC}
✅ Main website (index.html)
✅ Compliance page (compliance.html)
✅ Blog page (blog.html)
✅ Contact form (free-scan-form.html)
✅ Form handler (form-handler.js)
✅ Form backend (form-submit.php)

${BLUE}URLs:${NC}
🌐 Main site: https://xeops.ai
🔒 Compliance: https://xeops.ai/compliance.html
📝 Blog: https://xeops.ai/blog.html
📧 Contact form: https://xeops.ai/free-scan-form.html

${BLUE}Backup Location:${NC}
📁 Local: $BACKUP_DIR
📁 Remote: /tmp/xeops_backup_$BACKUP_DATE

${BLUE}Next Steps:${NC}
1. Test all pages manually
2. Verify form functionality
3. Check mobile responsiveness
4. Test language switching
5. Verify SSL certificate

${YELLOW}WordPress Admin:${NC}
🔑 Still accessible at: https://xeops.ai/wp-admin

${RED}Important Notes:${NC}
- Your WordPress installation is preserved
- Static files now serve as the main site
- Use rollback.sh if issues occur
- Regular backups recommended

EOF

# Save deployment log
echo "Deployment completed successfully at $(date)" >> "$BACKUP_DIR/deployment.log"

success "Deployment script completed successfully!"

exit 0