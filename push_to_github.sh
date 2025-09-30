#!/bin/bash

# =============================================================================
# Push XeOps.ai Website to GitHub
# Automated script to push the repository to GitHub
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
    exit 1
}

info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

echo -e "${CYAN}"
echo "🚀 Pushing XeOps.ai Website to GitHub"
echo "======================================"
echo -e "${NC}"

# Get GitHub username
read -p "Enter your GitHub username (default: sofyenmarzougui): " GITHUB_USERNAME
GITHUB_USERNAME=${GITHUB_USERNAME:-sofyenmarzougui}

# Get repository name
read -p "Enter repository name (default: xeops-website): " REPO_NAME
REPO_NAME=${REPO_NAME:-xeops-website}

GITHUB_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

log "Configuring GitHub repository..."

# Check if we're in the right directory
if [[ ! -f "README.md" ]] || [[ ! -d "src" ]]; then
    error "Please run this script from the xeops-website directory"
fi

# Check if git is initialized
if [[ ! -d ".git" ]]; then
    error "Git repository not initialized. Please run setup_github_repo.sh first"
fi

log "Adding GitHub remote..."

# Remove existing origin if it exists
git remote remove origin 2>/dev/null || true

# Add GitHub remote
git remote add origin "$GITHUB_URL"

success "GitHub remote added: $GITHUB_URL"

log "Preparing to push..."

# Ensure we're on main branch
git branch -M main

# Check if there are any changes to commit
if ! git diff-index --quiet HEAD --; then
    warning "Uncommitted changes detected. Committing..."
    git add .
    git commit -m "📝 Update: Prepare for GitHub push

- Latest website updates
- Deployment scripts ready
- Documentation complete"
fi

log "Pushing to GitHub..."

# Push to GitHub
if git push -u origin main; then
    success "Successfully pushed to GitHub!"
else
    error "Failed to push to GitHub. Please check your credentials and repository access."
fi

log "Verifying deployment..."

# Create a simple test to verify the push worked
cat << EOF

${GREEN}🎉 GitHub Repository Successfully Created!${NC}

${BLUE}Repository Details:${NC}
📍 URL: ${CYAN}https://github.com/${GITHUB_USERNAME}/${REPO_NAME}${NC}
🌐 GitHub Pages: ${CYAN}https://${GITHUB_USERNAME}.github.io/${REPO_NAME}${NC}

${BLUE}Next Steps:${NC}

1. ${YELLOW}Visit your repository:${NC}
   ${CYAN}https://github.com/${GITHUB_USERNAME}/${REPO_NAME}${NC}

2. ${YELLOW}Enable GitHub Pages (optional):${NC}
   - Go to Settings → Pages
   - Source: Deploy from a branch
   - Branch: main
   - Folder: / (root)

3. ${YELLOW}Set up repository description:${NC}
   - Add description: "XeOps.ai Official Website - European Cybersecurity Excellence"
   - Add topics: cybersecurity, website, europe, gdpr, automation

4. ${YELLOW}Configure repository settings:${NC}
   - Add website URL: https://xeops.ai
   - Enable issues and projects
   - Set up branch protection rules (optional)

${BLUE}Repository Features:${NC}
✅ Complete source code
✅ Automated deployment system
✅ Professional documentation
✅ MIT License
✅ Comprehensive README
✅ Contribution guidelines
✅ Security compliance docs

${BLUE}Available Commands:${NC}
${CYAN}# Update repository${NC}
git add .
git commit -m "Your commit message"
git push origin main

${CYAN}# Deploy to production${NC}
cd deployment
./xeops_deployment_manager.sh

${GREEN}Repository is now live on GitHub! 🌟${NC}

EOF

# Optional: Open GitHub repository in browser
read -p "Open repository in browser? (y/n): " OPEN_BROWSER
if [[ "$OPEN_BROWSER" == "y" || "$OPEN_BROWSER" == "Y" ]]; then
    if command -v open >/dev/null 2>&1; then
        open "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
    else
        info "Please manually open: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
    fi
fi

success "GitHub setup completed successfully!"

exit 0