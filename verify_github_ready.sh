#!/bin/bash

# =============================================================================
# GitHub Repository Verification Script
# Ensures everything is ready for GitHub deployment
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

echo -e "${CYAN}"
echo "🔍 GitHub Repository Verification"
echo "================================="
echo -e "${NC}"

ISSUES=0

log "Step 1: Checking repository structure..."

# Check if we're in the right directory
if [[ ! -f "README.md" ]] || [[ ! -d "src" ]]; then
    error "Not in the correct repository directory"
    exit 1
fi

# Check required directories
REQUIRED_DIRS=("src" "deployment" "docs" ".github/workflows")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        success "Directory exists: $dir"
    else
        error "Missing directory: $dir"
        ((ISSUES++))
    fi
done

log "Step 2: Checking required files..."

# Check source files
SOURCE_FILES=("src/index.html" "src/compliance.html" "src/blog.html" "src/free-scan-form.html" "src/form-handler.js" "src/form-submit.php")
for file in "${SOURCE_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        success "Source file exists: $(basename "$file")"
    else
        error "Missing source file: $file"
        ((ISSUES++))
    fi
done

# Check deployment scripts
DEPLOYMENT_SCRIPTS=("deployment/xeops_deployment_manager.sh" "deployment/prepare_deployment.sh" "deployment/deploy_xeops.sh" "deployment/monitor_deployment.sh")
for script in "${DEPLOYMENT_SCRIPTS[@]}"; do
    if [[ -f "$script" ]] && [[ -x "$script" ]]; then
        success "Deployment script ready: $(basename "$script")"
    else
        error "Missing or non-executable script: $script"
        ((ISSUES++))
    fi
done

# Check documentation
DOC_FILES=("README.md" "LICENSE" "docs/DEPLOYMENT.md" "docs/COMPLIANCE.md" "docs/CONTRIBUTING.md" "docs/GITHUB_SETUP.md")
for doc in "${DOC_FILES[@]}"; do
    if [[ -f "$doc" ]]; then
        success "Documentation exists: $(basename "$doc")"
    else
        error "Missing documentation: $doc"
        ((ISSUES++))
    fi
done

# Check GitHub workflows
if [[ -f ".github/workflows/deploy.yml" ]]; then
    success "GitHub Actions workflow ready"
else
    error "Missing GitHub Actions workflow"
    ((ISSUES++))
fi

log "Step 3: Validating file content..."

# Validate HTML files
for html_file in src/*.html; do
    if [[ -f "$html_file" ]]; then
        filename=$(basename "$html_file")
        if grep -q "<html" "$html_file" && grep -q "</html>" "$html_file"; then
            success "HTML structure valid: $filename"
        else
            warning "HTML structure issues in: $filename"
            ((ISSUES++))
        fi
    fi
done

# Validate JavaScript
for js_file in src/*.js; do
    if [[ -f "$js_file" ]]; then
        filename=$(basename "$js_file")
        if node -c "$js_file" 2>/dev/null; then
            success "JavaScript syntax valid: $filename"
        else
            warning "JavaScript syntax issues in: $filename"
            ((ISSUES++))
        fi
    fi
done

# Validate PHP
for php_file in src/*.php; do
    if [[ -f "$php_file" ]]; then
        filename=$(basename "$php_file")
        if php -l "$php_file" >/dev/null 2>&1; then
            success "PHP syntax valid: $filename"
        else
            warning "PHP syntax issues in: $filename"
            ((ISSUES++))
        fi
    fi
done

log "Step 4: Checking Git status..."

# Check if git is initialized
if [[ -d ".git" ]]; then
    success "Git repository initialized"

    # Check for uncommitted changes
    if git diff-index --quiet HEAD --; then
        success "No uncommitted changes"
    else
        warning "Uncommitted changes detected"
        git status --porcelain
    fi

    # Check current branch
    CURRENT_BRANCH=$(git branch --show-current)
    if [[ "$CURRENT_BRANCH" == "main" ]]; then
        success "On main branch"
    else
        warning "Not on main branch (currently on: $CURRENT_BRANCH)"
    fi

else
    error "Git repository not initialized"
    ((ISSUES++))
fi

log "Step 5: Security checks..."

# Check for sensitive files
SENSITIVE_PATTERNS=("*.key" "*.pem" "config.php" "wp-config.php" ".env")
for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    if find . -name "$pattern" -type f | grep -q .; then
        warning "Sensitive files found matching: $pattern"
        find . -name "$pattern" -type f
        ((ISSUES++))
    fi
done

# Check .gitignore
if [[ -f ".gitignore" ]]; then
    success ".gitignore file exists"

    # Check if sensitive patterns are ignored
    IGNORE_PATTERNS=("*.key" "*.env" "wp-config.php" "node_modules/" "vendor/")
    for pattern in "${IGNORE_PATTERNS[@]}"; do
        if grep -q "$pattern" .gitignore; then
            success "Ignoring: $pattern"
        else
            warning "Consider adding to .gitignore: $pattern"
        fi
    done
else
    error "Missing .gitignore file"
    ((ISSUES++))
fi

log "Step 6: Repository size check..."

# Check repository size
REPO_SIZE=$(du -sh . | cut -f1)
success "Repository size: $REPO_SIZE"

# Check for large files
LARGE_FILES=$(find . -type f -size +1M 2>/dev/null | grep -v ".git" || true)
if [[ -n "$LARGE_FILES" ]]; then
    warning "Large files detected (>1MB):"
    echo "$LARGE_FILES" | while read -r file; do
        echo "  - $file ($(du -h "$file" | cut -f1))"
    done
fi

log "Step 7: Final verification..."

# Count files
TOTAL_FILES=$(find src/ -type f | wc -l)
TOTAL_SCRIPTS=$(find deployment/ -name "*.sh" -type f | wc -l)
TOTAL_DOCS=$(find docs/ -name "*.md" -type f | wc -l)

success "Files ready for deployment:"
echo "  📄 Source files: $TOTAL_FILES"
echo "  🚀 Deployment scripts: $TOTAL_SCRIPTS"
echo "  📚 Documentation files: $TOTAL_DOCS"

# Summary
echo ""
echo "======================================"
if [[ $ISSUES -eq 0 ]]; then
    echo -e "${GREEN}🎉 Repository is ready for GitHub!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Run: ${CYAN}./push_to_github.sh${NC}"
    echo "2. Configure GitHub repository settings"
    echo "3. Enable GitHub Pages"
    echo "4. Set up branch protection"
    echo ""
    echo -e "${GREEN}All systems go! 🚀${NC}"
else
    echo -e "${RED}❌ Found $ISSUES issues that need attention${NC}"
    echo ""
    echo -e "${YELLOW}Please fix the issues above before pushing to GitHub${NC}"
    exit 1
fi

exit 0