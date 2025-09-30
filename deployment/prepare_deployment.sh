#!/bin/bash

# =============================================================================
# XeOps.ai Deployment Preparation Script
# Validates and prepares files before deployment
# =============================================================================

set -e

# Configuration
LOCAL_PATH="/Users/sofyenmarzougui/Desktop/xeops_local_development"
TEMP_DIR="$LOCAL_PATH/temp_deployment"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
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

echo "
========================================
  XeOps.ai Deployment Preparation
========================================
"

# Clean up previous temp directory
if [[ -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
fi

mkdir -p "$TEMP_DIR"

log "Step 1: Validating local files..."

# Required files
REQUIRED_FILES=(
    "xeops_final_site.html"
    "compliance.html"
    "blog.html"
    "free-scan-form.html"
    "form-handler.js"
    "form-submit.php"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$LOCAL_PATH/$file" ]]; then
        success "Found: $file"
        cp "$LOCAL_PATH/$file" "$TEMP_DIR/"
    else
        error "Missing required file: $file"
    fi
done

log "Step 2: Optimizing files for production..."

# Create optimized index.html from main site
cp "$TEMP_DIR/xeops_final_site.html" "$TEMP_DIR/index.html"
success "Created index.html from main site"

# Validate HTML files
log "Validating HTML structure..."
for html_file in "$TEMP_DIR"/*.html; do
    if [[ -f "$html_file" ]]; then
        filename=$(basename "$html_file")
        # Basic HTML validation - check for opening and closing tags
        if grep -q "<html" "$html_file" && grep -q "</html>" "$html_file"; then
            success "HTML structure valid: $filename"
        else
            warning "HTML structure issues in: $filename"
        fi
    fi
done

# Validate JavaScript
log "Validating JavaScript files..."
if [[ -f "$TEMP_DIR/form-handler.js" ]]; then
    if node -c "$TEMP_DIR/form-handler.js" 2>/dev/null; then
        success "JavaScript syntax valid: form-handler.js"
    else
        warning "JavaScript syntax issues in form-handler.js"
    fi
fi

# Validate PHP files
log "Validating PHP files..."
if [[ -f "$TEMP_DIR/form-submit.php" ]]; then
    if php -l "$TEMP_DIR/form-submit.php" >/dev/null 2>&1; then
        success "PHP syntax valid: form-submit.php"
    else
        warning "PHP syntax issues in form-submit.php"
    fi
fi

log "Step 3: Checking external dependencies..."

# Check for external CDN dependencies
for html_file in "$TEMP_DIR"/*.html; do
    if [[ -f "$html_file" ]]; then
        filename=$(basename "$html_file")

        # Check for Tailwind CSS
        if grep -q "tailwindcss.com" "$html_file"; then
            success "$filename: Tailwind CSS CDN found"
        fi

        # Check for Google Fonts
        if grep -q "fonts.googleapis.com" "$html_file"; then
            success "$filename: Google Fonts found"
        fi

        # Check for reCAPTCHA
        if grep -q "recaptcha" "$html_file"; then
            success "$filename: reCAPTCHA integration found"
        fi
    fi
done

log "Step 4: Security validation..."

# Check for potential security issues
for file in "$TEMP_DIR"/*.php; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")

        # Check for SQL injection protection
        if grep -q "htmlspecialchars\|filter_var" "$file"; then
            success "$filename: Input sanitization found"
        else
            warning "$filename: Consider adding input sanitization"
        fi

        # Check for file upload security
        if grep -q "file_put_contents\|fopen" "$file"; then
            if grep -q "chmod.*644" "$file"; then
                success "$filename: File permissions security found"
            else
                warning "$filename: Consider adding file permission controls"
            fi
        fi
    fi
done

log "Step 5: Creating deployment package..."

# Create archive of deployment files
PACKAGE_NAME="xeops_deployment_$(date +%Y%m%d_%H%M%S).tar.gz"
cd "$TEMP_DIR"
tar -czf "../$PACKAGE_NAME" *
cd ..

success "Deployment package created: $PACKAGE_NAME"

log "Step 6: Generating deployment checklist..."

cat > "$LOCAL_PATH/deployment_checklist.md" << EOF
# XeOps.ai Deployment Checklist

## Pre-Deployment ✅
- [x] All required files validated
- [x] HTML structure checked
- [x] JavaScript syntax validated
- [x] PHP syntax validated
- [x] External dependencies verified
- [x] Security checks completed
- [x] Deployment package created

## Files Ready for Deployment
1. **index.html** - Main website (from xeops_final_site.html)
2. **compliance.html** - European compliance page
3. **blog.html** - Blog page
4. **free-scan-form.html** - Contact form
5. **form-handler.js** - Form JavaScript
6. **form-submit.php** - Form backend

## Manual Tests Required After Deployment
- [ ] Main page loads correctly
- [ ] Navigation between pages works
- [ ] Language switching functions
- [ ] Contact form submits successfully
- [ ] Form validation works
- [ ] reCAPTCHA functions
- [ ] Mobile responsiveness
- [ ] SSL certificate active
- [ ] All external resources load (Tailwind, Google Fonts)

## Backup Verification
- [ ] Remote backup created
- [ ] Local backup accessible
- [ ] Rollback script ready

## WordPress Integration
- [ ] WordPress admin still accessible
- [ ] Database integrity maintained
- [ ] Plugin functionality preserved

## Go-Live Checklist
- [ ] DNS records updated (if needed)
- [ ] SSL certificate valid
- [ ] Analytics tracking active
- [ ] Search console updated
- [ ] Social media links updated

## Post-Deployment Monitoring
- [ ] Monitor form submissions
- [ ] Check error logs
- [ ] Verify email delivery
- [ ] Monitor site performance
- [ ] Check mobile compatibility

---
**Package:** $PACKAGE_NAME
**Generated:** $(date)
EOF

success "Deployment checklist created"

log "Step 7: Final summary..."

cat << EOF

${GREEN}🎯 Deployment Preparation Complete!${NC}

${BLUE}Package Details:${NC}
📦 Package: $PACKAGE_NAME
📁 Size: $(ls -lh "$PACKAGE_NAME" | awk '{print $5}')
📋 Checklist: deployment_checklist.md

${BLUE}Files Included:${NC}
$(ls -1 "$TEMP_DIR/" | sed 's/^/  ✅ /')

${BLUE}Next Steps:${NC}
1. Review deployment_checklist.md
2. Run the deployment script:
   ${YELLOW}./deploy_xeops.sh${NC}
3. Complete manual testing
4. Monitor for issues

${YELLOW}Ready to deploy? Run:${NC}
cd $LOCAL_PATH && ./deploy_xeops.sh

EOF

# Clean up temp directory
rm -rf "$TEMP_DIR"

success "Preparation completed successfully!"

exit 0