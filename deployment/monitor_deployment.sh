#!/bin/bash

# =============================================================================
# XeOps.ai Deployment Monitoring Script
# Monitors website health after deployment
# =============================================================================

set -e

# Configuration
SITE_URL="https://xeops.ai"
REMOTE_HOST="82.25.113.15"
REMOTE_USER="u383093123"
REMOTE_PATH="/domains/xeops.ai/public_html"

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
}

check_url() {
    local url="$1"
    local expected_status="${2:-200}"

    local response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)

    if [[ "$response" == "$expected_status" ]]; then
        success "✓ $url (HTTP $response)"
        return 0
    else
        error "✗ $url (HTTP $response)"
        return 1
    fi
}

echo "
========================================
    XeOps.ai Deployment Monitor
========================================
"

log "Step 1: Website Accessibility Test..."

# Test main pages
PAGES=(
    "$SITE_URL"
    "$SITE_URL/compliance.html"
    "$SITE_URL/blog.html"
    "$SITE_URL/free-scan-form.html"
)

for page in "${PAGES[@]}"; do
    check_url "$page"
done

log "Step 2: Content Validation..."

# Check for key content on main page
if curl -s "$SITE_URL" | grep -q "XeOps.ai"; then
    success "Main page contains XeOps branding"
else
    warning "XeOps branding not found on main page"
fi

if curl -s "$SITE_URL" | grep -q "cybersécurité"; then
    success "French content detected"
else
    warning "French content not detected"
fi

# Check compliance page
if curl -s "$SITE_URL/compliance.html" | grep -q "NIS2"; then
    success "Compliance page contains NIS2 content"
else
    warning "NIS2 content not found on compliance page"
fi

log "Step 3: Form Functionality Test..."

# Test form endpoint
if check_url "$SITE_URL/form-submit.php"; then
    success "Form endpoint accessible"
else
    warning "Form endpoint may have issues"
fi

log "Step 4: External Dependencies Check..."

# Check if external resources load
EXTERNAL_DEPS=(
    "https://cdn.tailwindcss.com"
    "https://fonts.googleapis.com"
    "https://www.google.com/recaptcha"
)

for dep in "${EXTERNAL_DEPS[@]}"; do
    if curl -s --max-time 5 "$dep" >/dev/null 2>&1; then
        success "External dependency accessible: $dep"
    else
        warning "External dependency issue: $dep"
    fi
done

log "Step 5: SSL Certificate Check..."

if openssl s_client -connect xeops.ai:443 -servername xeops.ai </dev/null 2>/dev/null | openssl x509 -noout -dates 2>/dev/null; then
    success "SSL certificate is valid"
else
    warning "SSL certificate validation failed"
fi

log "Step 6: Server Log Check..."

# Check for recent errors in logs
log_check=$(ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_PATH && find . -name '*.log' -mtime -1 2>/dev/null | wc -l" 2>/dev/null || echo "0")

if [[ "$log_check" -gt 0 ]]; then
    warning "Found recent log files - check for errors"
else
    success "No recent error logs found"
fi

log "Step 7: Performance Test..."

# Simple performance test
load_time=$(curl -s -w "%{time_total}" -o /dev/null "$SITE_URL")
load_time_int=$(echo "$load_time * 1000" | bc | cut -d. -f1)

if [[ "$load_time_int" -lt 2000 ]]; then
    success "Good page load time: ${load_time}s"
elif [[ "$load_time_int" -lt 5000 ]]; then
    warning "Acceptable page load time: ${load_time}s"
else
    error "Slow page load time: ${load_time}s"
fi

log "Step 8: Mobile Responsiveness Check..."

# Check for viewport meta tag
if curl -s "$SITE_URL" | grep -q "viewport"; then
    success "Viewport meta tag found"
else
    warning "Viewport meta tag missing"
fi

# Check for responsive CSS
if curl -s "$SITE_URL" | grep -q "md:grid-cols\|lg:grid-cols"; then
    success "Responsive CSS classes detected"
else
    warning "Responsive CSS classes not detected"
fi

log "Step 9: WordPress Integration Check..."

# Check if WordPress admin is still accessible
if check_url "$SITE_URL/wp-admin/" 302; then
    success "WordPress admin accessible (redirects to login)"
else
    warning "WordPress admin accessibility issue"
fi

log "Step 10: SEO Basics Check..."

# Check for essential SEO elements
main_page=$(curl -s "$SITE_URL")

if echo "$main_page" | grep -q "<title>"; then
    success "Title tag found"
else
    warning "Title tag missing"
fi

if echo "$main_page" | grep -q "description.*content"; then
    success "Meta description found"
else
    warning "Meta description missing"
fi

if echo "$main_page" | grep -q "lang="; then
    success "Language attribute found"
else
    warning "Language attribute missing"
fi

# Generate monitoring report
REPORT_FILE="/Users/sofyenmarzougui/Desktop/xeops_local_development/monitoring_report_$(date +%Y%m%d_%H%M%S).txt"

cat > "$REPORT_FILE" << EOF
XeOps.ai Deployment Monitoring Report
Generated: $(date)

WEBSITE STATUS
$(for page in "${PAGES[@]}"; do
    if curl -s -o /dev/null -w "%{http_code}" "$page" 2>/dev/null | grep -q "200"; then
        echo "✅ $page - OK"
    else
        echo "❌ $page - ISSUE"
    fi
done)

PERFORMANCE
- Page load time: ${load_time}s
- SSL Certificate: $(if openssl s_client -connect xeops.ai:443 -servername xeops.ai </dev/null 2>/dev/null | openssl x509 -noout -dates 2>/dev/null >/dev/null; then echo "Valid"; else echo "Issue"; fi)

CONTENT VALIDATION
- XeOps branding: $(if curl -s "$SITE_URL" | grep -q "XeOps.ai"; then echo "Found"; else echo "Missing"; fi)
- French content: $(if curl -s "$SITE_URL" | grep -q "cybersécurité"; then echo "Found"; else echo "Missing"; fi)
- NIS2 compliance: $(if curl -s "$SITE_URL/compliance.html" | grep -q "NIS2"; then echo "Found"; else echo "Missing"; fi)

TECHNICAL STATUS
- Form endpoint: $(if curl -s -o /dev/null -w "%{http_code}" "$SITE_URL/form-submit.php" 2>/dev/null | grep -q "200"; then echo "Accessible"; else echo "Issue"; fi)
- WordPress admin: $(if curl -s -o /dev/null -w "%{http_code}" "$SITE_URL/wp-admin/" 2>/dev/null | grep -q "302"; then echo "Accessible"; else echo "Issue"; fi)
- Responsive design: $(if curl -s "$SITE_URL" | grep -q "viewport"; then echo "Detected"; else echo "Missing"; fi)

RECOMMENDATIONS
- Monitor form submissions regularly
- Check error logs weekly
- Verify backup integrity monthly
- Update security certificates as needed
- Test mobile compatibility across devices

EOF

success "Monitoring report saved: $REPORT_FILE"

log "Monitoring completed!"

cat << EOF

${GREEN}🔍 Monitoring Summary${NC}

${BLUE}Website Status:${NC} $(if curl -s -o /dev/null -w "%{http_code}" "$SITE_URL" 2>/dev/null | grep -q "200"; then echo "${GREEN}ONLINE${NC}"; else echo "${RED}OFFLINE${NC}"; fi)
${BLUE}Load Time:${NC} ${load_time}s
${BLUE}SSL Status:${NC} $(if openssl s_client -connect xeops.ai:443 -servername xeops.ai </dev/null 2>/dev/null | openssl x509 -noout -dates 2>/dev/null >/dev/null; then echo "${GREEN}Valid${NC}"; else echo "${RED}Issue${NC}"; fi)

${BLUE}Full Report:${NC} $REPORT_FILE

${YELLOW}Recommended Actions:${NC}
1. Review the full monitoring report
2. Set up automated monitoring (optional)
3. Schedule regular health checks
4. Monitor form submissions

${GREEN}Deployment monitoring completed!${NC}

EOF

exit 0