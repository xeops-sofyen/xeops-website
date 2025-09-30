#!/bin/bash

# =============================================================================
# XeOps.ai Deployment Manager
# Master script to manage the entire deployment process
# =============================================================================

set -e

# Configuration
SCRIPT_DIR="/Users/sofyenmarzougui/Desktop/xeops_local_development"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Enhanced logging
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

# Banner with ASCII art
show_banner() {
    echo -e "${PURPLE}"
    cat << 'EOF'
    ██╗  ██╗███████╗ ██████╗ ██████╗ ███████╗
    ╚██╗██╔╝██╔════╝██╔═══██╗██╔══██╗██╔════╝
     ╚███╔╝ █████╗  ██║   ██║██████╔╝███████╗
     ██╔██╗ ██╔══╝  ██║   ██║██╔═══╝ ╚════██║
    ██╔╝ ██╗███████╗╚██████╔╝██║     ███████║
    ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝     ╚══════╝
EOF
    echo -e "${NC}"
    echo -e "${CYAN}    Automated Deployment Manager v1.0${NC}"
    echo -e "${CYAN}    European Cybersecurity Excellence${NC}"
    echo ""
}

# Menu function
show_menu() {
    echo -e "${YELLOW}📋 Available Options:${NC}"
    echo ""
    echo "  1️⃣  Prepare Deployment    - Validate and prepare files"
    echo "  2️⃣  Deploy to Production  - Deploy to Hostinger"
    echo "  3️⃣  Monitor Deployment   - Check deployment health"
    echo "  4️⃣  Full Deployment      - Complete automated process"
    echo "  5️⃣  Rollback Deployment  - Restore previous version"
    echo "  6️⃣  View Logs           - Show deployment history"
    echo "  7️⃣  Help & Documentation"
    echo "  0️⃣  Exit"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."

    # Check if scripts exist
    local scripts=("prepare_deployment.sh" "deploy_xeops.sh" "monitor_deployment.sh")
    for script in "${scripts[@]}"; do
        if [[ -f "$SCRIPT_DIR/$script" ]]; then
            success "Found: $script"
        else
            error "Missing script: $script"
        fi
    done

    # Check required tools
    local tools=("curl" "ssh" "scp" "tar" "php" "node")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            success "Tool available: $tool"
        else
            warning "Tool missing: $tool (may affect functionality)"
        fi
    done
}

# Prepare deployment
prepare_deployment() {
    log "Starting deployment preparation..."

    if [[ -f "$SCRIPT_DIR/prepare_deployment.sh" ]]; then
        cd "$SCRIPT_DIR"
        ./prepare_deployment.sh
        success "Preparation completed"
    else
        error "Preparation script not found"
    fi
}

# Deploy to production
deploy_to_production() {
    log "Starting production deployment..."

    # Confirmation prompt
    echo -e "${YELLOW}⚠️  This will replace your live website!${NC}"
    echo -e "${YELLOW}   Make sure you have backups ready.${NC}"
    echo ""
    read -p "Are you sure you want to proceed? (yes/no): " confirm

    if [[ "$confirm" == "yes" ]]; then
        if [[ -f "$SCRIPT_DIR/deploy_xeops.sh" ]]; then
            cd "$SCRIPT_DIR"
            ./deploy_xeops.sh
            success "Deployment completed"
        else
            error "Deployment script not found"
        fi
    else
        info "Deployment cancelled by user"
    fi
}

# Monitor deployment
monitor_deployment() {
    log "Starting deployment monitoring..."

    if [[ -f "$SCRIPT_DIR/monitor_deployment.sh" ]]; then
        cd "$SCRIPT_DIR"
        ./monitor_deployment.sh
        success "Monitoring completed"
    else
        error "Monitoring script not found"
    fi
}

# Full automated deployment
full_deployment() {
    log "Starting full automated deployment process..."

    echo -e "${YELLOW}🚀 Full Deployment Process:${NC}"
    echo "  1. Preparation and validation"
    echo "  2. Deployment to production"
    echo "  3. Health monitoring"
    echo ""

    read -p "Continue with full deployment? (yes/no): " confirm

    if [[ "$confirm" == "yes" ]]; then
        # Step 1: Prepare
        echo -e "\n${BLUE}═══ Step 1: Preparation ═══${NC}"
        prepare_deployment

        # Step 2: Deploy
        echo -e "\n${BLUE}═══ Step 2: Deployment ═══${NC}"
        cd "$SCRIPT_DIR"
        ./deploy_xeops.sh

        # Step 3: Monitor
        echo -e "\n${BLUE}═══ Step 3: Monitoring ═══${NC}"
        sleep 5  # Give deployment time to settle
        ./monitor_deployment.sh

        echo -e "\n${GREEN}🎉 Full deployment process completed!${NC}"
    else
        info "Full deployment cancelled"
    fi
}

# Rollback deployment
rollback_deployment() {
    log "Searching for rollback scripts..."

    # Find latest backup directory
    local backup_dir=$(find "$SCRIPT_DIR/backups" -name "rollback.sh" 2>/dev/null | head -1 | xargs dirname)

    if [[ -n "$backup_dir" && -f "$backup_dir/rollback.sh" ]]; then
        echo -e "${YELLOW}Found rollback script in: $backup_dir${NC}"
        echo ""
        read -p "Execute rollback? This will restore the previous version. (yes/no): " confirm

        if [[ "$confirm" == "yes" ]]; then
            cd "$backup_dir"
            ./rollback.sh
            success "Rollback completed"
        else
            info "Rollback cancelled"
        fi
    else
        warning "No rollback script found. Please check backups directory."
    fi
}

# View logs
view_logs() {
    log "Searching for deployment logs..."

    if [[ -d "$SCRIPT_DIR/backups" ]]; then
        echo -e "${BLUE}Recent deployments:${NC}"
        ls -la "$SCRIPT_DIR/backups" | tail -10
        echo ""

        echo -e "${BLUE}Deployment packages:${NC}"
        ls -la "$SCRIPT_DIR"/*.tar.gz 2>/dev/null | tail -5 || echo "No packages found"
        echo ""

        echo -e "${BLUE}Monitoring reports:${NC}"
        ls -la "$SCRIPT_DIR"/monitoring_report_*.txt 2>/dev/null | tail -5 || echo "No monitoring reports found"
    else
        warning "No logs directory found"
    fi
}

# Show help
show_help() {
    cat << EOF

${CYAN}XeOps.ai Deployment Manager Help${NC}

${YELLOW}Overview:${NC}
This deployment manager automates the process of deploying your XeOps.ai
website from local development to your Hostinger production server.

${YELLOW}Process Flow:${NC}
1. ${BLUE}Prepare${NC} - Validates files and creates deployment package
2. ${BLUE}Deploy${NC}  - Uploads files to production server with backup
3. ${BLUE}Monitor${NC} - Verifies deployment and checks website health

${YELLOW}Files Deployed:${NC}
• index.html (main website)
• compliance.html (European compliance page)
• blog.html (blog page)
• free-scan-form.html (contact form)
• form-handler.js (form JavaScript)
• form-submit.php (form backend)

${YELLOW}Safety Features:${NC}
• Automatic backups before deployment
• Rollback capability
• Health monitoring
• WordPress preservation
• Input validation

${YELLOW}Prerequisites:${NC}
• SSH access to Hostinger server
• Local development files
• Internet connection
• Required tools (curl, ssh, scp, tar)

${YELLOW}Troubleshooting:${NC}
• Check logs in backups/ directory
• Use monitoring tool to diagnose issues
• Rollback if deployment fails
• Verify file permissions and syntax

${YELLOW}Support:${NC}
• Check deployment_checklist.md for manual steps
• Review monitoring reports for health status
• Use rollback script in case of issues

EOF
}

# Main function
main() {
    show_banner

    # Check if we're in the right directory
    if [[ ! -f "$SCRIPT_DIR/xeops_final_site.html" ]]; then
        error "Please run this script from the XeOps development directory"
    fi

    check_prerequisites

    while true; do
        echo ""
        show_menu
        read -p "Select an option (0-7): " choice

        case $choice in
            1)
                prepare_deployment
                ;;
            2)
                deploy_to_production
                ;;
            3)
                monitor_deployment
                ;;
            4)
                full_deployment
                ;;
            5)
                rollback_deployment
                ;;
            6)
                view_logs
                ;;
            7)
                show_help
                ;;
            0)
                echo -e "${GREEN}👋 Goodbye! Safe deployments!${NC}"
                exit 0
                ;;
            *)
                warning "Invalid option. Please select 0-7."
                ;;
        esac

        echo ""
        read -p "Press Enter to continue..."
    done
}

# Handle script interruption
trap 'echo -e "\n${YELLOW}⚠️  Deployment interrupted by user${NC}"; exit 1' INT

# Run main function
main "$@"