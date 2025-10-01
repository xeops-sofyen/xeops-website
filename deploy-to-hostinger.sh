#!/bin/bash

#######################################################
# XeOps Website Deployment Script to Hostinger
# This script deploys the website via FTP
#######################################################

set -e

echo "======================================"
echo "XeOps Website Deployment to Hostinger"
echo "======================================"
echo ""

# FTP Configuration
FTP_HOST="82.25.113.15"
FTP_USER="u383093123"
FTP_PORT="21"
FTP_REMOTE_DIR="/public_html"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if lftp is installed
if ! command -v lftp &> /dev/null; then
    echo -e "${RED}Error: lftp is not installed${NC}"
    echo "Please install it:"
    echo "  macOS: brew install lftp"
    echo "  Ubuntu/Debian: sudo apt-get install lftp"
    echo "  CentOS/RHEL: sudo yum install lftp"
    exit 1
fi

# Prompt for FTP password securely
echo -e "${YELLOW}Please enter your FTP password:${NC}"
read -s FTP_PASS
echo ""

# Verify connection
echo -e "${BLUE}Testing FTP connection...${NC}"
lftp -u "$FTP_USER,$FTP_PASS" -p $FTP_PORT $FTP_HOST <<EOF
ls
bye
EOF

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to connect to FTP server${NC}"
    exit 1
fi

echo -e "${GREEN}✓ FTP connection successful${NC}"
echo ""

# Create list of files to upload
echo -e "${BLUE}Preparing files for upload...${NC}"

# Upload files using lftp
echo -e "${BLUE}Uploading files to Hostinger...${NC}"
lftp -u "$FTP_USER,$FTP_PASS" -p $FTP_PORT $FTP_HOST <<EOF
set ftp:ssl-allow no
set net:timeout 10
set net:max-retries 2
set net:reconnect-interval-base 5

# Navigate to remote directory
cd $FTP_REMOTE_DIR

# Upload HTML files
echo "Uploading HTML files..."
put src/index.html -o index.html
put src/free-scan-form.html -o free-scan-form.html
put src/blog.html -o blog.html
put src/compliance.html -o compliance.html

# Upload PHP files
echo "Uploading PHP backend files..."
put src/config.php -o config.php
put src/form-submit.php -o form-submit.php
put src/email-sender.php -o email-sender.php

# Upload JavaScript files
echo "Uploading JavaScript files..."
put src/form-handler.js -o form-handler.js

# Create necessary directories on server
mkdir -p scan_requests
mkdir -p logs
chmod 755 scan_requests
chmod 755 logs

# Upload .env file if it exists (be careful with sensitive data!)
# put .env -o .env

echo "Upload complete!"
bye
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}======================================"
    echo -e "✓ Deployment Successful!"
    echo -e "======================================${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Configure your .env file on the server with SMTP credentials"
    echo "2. Test the form at: https://www.xeops.ai/free-scan-form.html"
    echo "3. Verify email delivery to contact@xeops.ai"
    echo "4. Check that scan_requests/ and logs/ directories are writable"
    echo ""
    echo -e "${YELLOW}Important Security Notes:${NC}"
    echo "- Make sure .env file has proper permissions (chmod 600)"
    echo "- Update reCAPTCHA keys in config.php with production keys"
    echo "- Test the form thoroughly before announcing to clients"
else
    echo -e "${RED}Deployment failed!${NC}"
    exit 1
fi
