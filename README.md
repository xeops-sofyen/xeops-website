# 🌐 XeOps.ai Website

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Deployment](https://img.shields.io/badge/Deployment-Automated-brightgreen.svg)](./deployment/)
[![Compliance](https://img.shields.io/badge/GDPR-Compliant-blue.svg)](./src/compliance.html)

> **European Cybersecurity Excellence** - Official showcase website for XeOps.ai, the AI-powered cybersecurity automation platform.

## 🎯 Overview

This repository contains the complete showcase website for XeOps.ai, featuring:

- 🌍 **European Compliance**: Full GDPR, NIS2, and ANSSI compliance
- 🚀 **Automated Deployment**: One-click deployment to production
- 🔒 **Secure Forms**: Contact forms with reCAPTCHA and data validation
- 🌐 **Multilingual**: French and English support with automatic detection
- 📱 **Responsive Design**: Mobile-first design with Tailwind CSS

## 📁 Project Structure

```
xeops-website/
├── 📄 src/                    # Website source files
│   ├── index.html             # Main landing page
│   ├── compliance.html        # European compliance page
│   ├── blog.html             # Blog page
│   ├── free-scan-form.html   # Contact form
│   ├── form-handler.js       # Form JavaScript
│   └── form-submit.php       # Form backend
│
├── 🚀 deployment/            # Deployment automation
│   ├── xeops_deployment_manager.sh  # Main deployment script
│   ├── prepare_deployment.sh        # File preparation
│   ├── deploy_xeops.sh             # Production deployment
│   └── monitor_deployment.sh       # Health monitoring
│
├── 📚 docs/                  # Documentation
│   ├── DEPLOYMENT.md         # Deployment guide
│   ├── COMPLIANCE.md         # Compliance information
│   └── CONTRIBUTING.md       # Contribution guidelines
│
└── 🎨 assets/               # Static assets
    ├── images/              # Image files
    ├── icons/               # Icon files
    └── fonts/               # Custom fonts
```

## 🚀 Quick Start

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/sofyenmarzougui/xeops-website.git
   cd xeops-website
   ```

2. **Open in browser**
   ```bash
   open src/index.html
   ```

### Production Deployment

1. **Run deployment manager**
   ```bash
   cd deployment
   ./xeops_deployment_manager.sh
   ```

2. **Choose deployment option**
   - Option 4: Full automated deployment
   - Includes validation, deployment, and monitoring

## 🌍 Live Website

- **Production**: [https://xeops.ai](https://xeops.ai)
- **Compliance**: [https://xeops.ai/compliance.html](https://xeops.ai/compliance.html)
- **Blog**: [https://xeops.ai/blog.html](https://xeops.ai/blog.html)
- **Contact**: [https://xeops.ai/free-scan-form.html](https://xeops.ai/free-scan-form.html)

## ✨ Features

### 🔒 European Compliance
- **GDPR**: Complete data protection compliance
- **NIS2**: Network and Information Security Directive 2
- **ANSSI**: French cybersecurity agency recommendations
- **European Hosting**: Data never leaves EU soil

### 🌐 Multilingual Support
- **Auto-detection**: Language based on referrer
- **Persistence**: User preferences saved
- **Complete Translation**: All content in FR/EN

### 📱 Modern Design
- **Responsive**: Mobile-first approach
- **Tailwind CSS**: Modern utility-first framework
- **Accessibility**: WCAG 2.1 compliant
- **Performance**: Optimized loading times

### 🚀 Automated Deployment
- **One-click deployment**: Complete automation
- **Backup system**: Automatic rollback capability
- **Health monitoring**: Post-deployment verification
- **WordPress integration**: Preserves existing WP installation

## 🛡️ Security

- ✅ **Input Validation**: All forms sanitized
- ✅ **reCAPTCHA**: Spam protection
- ✅ **HTTPS**: SSL/TLS encryption
- ✅ **File Permissions**: Secure server configuration
- ✅ **Data Privacy**: GDPR compliant data handling

## 📊 Technology Stack

- **Frontend**: HTML5, CSS3 (Tailwind), JavaScript (ES6+)
- **Backend**: PHP 8.0+
- **Hosting**: Hostinger (European servers)
- **CDN**: Tailwind CSS, Google Fonts
- **Security**: reCAPTCHA v2, HTTPS

## 🤝 Contributing

Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Documentation**: [/docs](./docs/)
- **Issues**: [GitHub Issues](https://github.com/sofyenmarzougui/xeops-website/issues)
- **Security**: security@xeops.ai

---

**Made with ❤️ by the XeOps.ai team**

*European Cybersecurity Excellence*
