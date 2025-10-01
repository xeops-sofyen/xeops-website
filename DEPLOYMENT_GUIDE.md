# 🚀 Guide de Déploiement - XeOps.ai Website

## 📋 Prérequis

### Sur votre machine locale:
- `lftp` installé pour le transfert FTP
  - **macOS**: `brew install lftp`
  - **Ubuntu/Debian**: `sudo apt-get install lftp`
  - **CentOS/RHEL**: `sudo yum install lftp`

### Sur le serveur Hostinger:
- PHP 7.4+ (recommandé 8.0+)
- Support mail() ou SMTP
- Permissions d'écriture pour `scan_requests/` et `logs/`

## 🔐 Configuration des Variables d'Environnement

### 1. Créer le fichier .env sur le serveur

Après le déploiement, connectez-vous via FTP/SFTP et créez un fichier `.env` dans `/public_html/` :

```env
# Configuration SMTP pour l'envoi d'emails
SMTP_HOST=smtp.hostinger.com
SMTP_PORT=587
SMTP_USER=contact@xeops.ai
SMTP_PASS=votre_mot_de_passe_smtp
SMTP_FROM=contact@xeops.ai
SMTP_FROM_NAME=XeOps.ai

# Destinataires des emails
EMAIL_TO=contact@xeops.ai
EMAIL_ADMIN=contact@xeops.ai
```

### 2. Mettre à jour les clés reCAPTCHA

Dans `config.php`, remplacez la clé de test par votre clé de production:

```php
// Remplacer cette ligne:
define('RECAPTCHA_SECRET_KEY', '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe');

// Par votre clé réelle:
define('RECAPTCHA_SECRET_KEY', 'VOTRE_CLE_RECAPTCHA_SECRETE');
```

Et dans `free-scan-form.html`, ligne 446:

```html
<!-- Remplacer -->
<div class="g-recaptcha" data-sitekey="6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"></div>

<!-- Par -->
<div class="g-recaptcha" data-sitekey="VOTRE_CLE_SITE_RECAPTCHA"></div>
```

## 🚀 Déploiement Automatisé

### Option 1: Script de déploiement (Recommandé)

```bash
# Dans le répertoire du projet
./deploy-to-hostinger.sh
```

Le script vous demandera le mot de passe FTP et uploadera automatiquement tous les fichiers nécessaires.

### Option 2: Déploiement Manuel via FTP

#### A. Fichiers à uploader dans `/public_html/`:

**Fichiers HTML:**
- `src/index.html` → `index.html`
- `src/free-scan-form.html` → `free-scan-form.html`
- `src/blog.html` → `blog.html`
- `src/compliance.html` → `compliance.html`

**Fichiers PHP (Backend):**
- `src/config.php` → `config.php`
- `src/form-submit.php` → `form-submit.php`
- `src/email-sender.php` → `email-sender.php`

**Fichiers JavaScript:**
- `src/form-handler.js` → `form-handler.js`

#### B. Créer les répertoires nécessaires:

```bash
/public_html/scan_requests/  (chmod 755)
/public_html/logs/           (chmod 755)
```

#### C. Créer le fichier .env:

Créez `/public_html/.env` avec vos identifiants SMTP (voir section Configuration ci-dessus)

## ✅ Vérification Post-Déploiement

### 1. Test de la connexion au serveur

Visitez: `https://www.xeops.ai/`
- ✅ La page d'accueil doit se charger correctement

### 2. Test du formulaire

Visitez: `https://www.xeops.ai/free-scan-form.html`

- ✅ Le formulaire doit s'afficher correctement
- ✅ Le reCAPTCHA doit être visible
- ✅ La validation côté client doit fonctionner

### 3. Test de soumission

1. Remplissez le formulaire avec des données de test
2. Soumettez le formulaire
3. Vérifiez:
   - ✅ Message de succès affiché
   - ✅ Email reçu à `contact@xeops.ai`
   - ✅ Fichier JSON créé dans `/scan_requests/`
   - ✅ Entrée dans `/logs/form_submissions.log`

### 4. Vérification des permissions

```bash
# Via FTP ou SSH
ls -la scan_requests/
ls -la logs/

# Les dossiers doivent être accessibles en écriture (755 ou 775)
```

## 📧 Configuration SMTP pour Hostinger

### Obtenir les identifiants SMTP:

1. Connectez-vous à votre panneau Hostinger
2. Allez dans **Emails** → Sélectionnez votre email `contact@xeops.ai`
3. Notez les paramètres SMTP:
   - **Serveur**: `smtp.hostinger.com`
   - **Port**: `587` (TLS) ou `465` (SSL)
   - **Nom d'utilisateur**: `contact@xeops.ai`
   - **Mot de passe**: Votre mot de passe email

### Test de l'envoi d'email:

Créez un fichier `test-email.php` temporaire:

```php
<?php
require_once 'config.php';
require_once 'email-sender.php';

$emailSender = new EmailSender();
$result = $emailSender->send(
    'contact@xeops.ai',
    'Test Email from XeOps',
    'This is a test email. If you receive this, email sending is working correctly!'
);

echo $result ? 'Email sent successfully!' : 'Failed to send email.';
?>
```

Visitez `https://www.xeops.ai/test-email.php` puis supprimez le fichier.

## 🔒 Sécurité

### Permissions recommandées:

```bash
chmod 644 *.php          # Fichiers PHP
chmod 644 *.html         # Fichiers HTML
chmod 644 *.js           # Fichiers JavaScript
chmod 600 .env           # Fichier de configuration (TRÈS IMPORTANT)
chmod 755 scan_requests/ # Dossier des scans
chmod 755 logs/          # Dossier des logs
```

### Fichiers à NE PAS uploader:

- ❌ `.git/` (dossier Git)
- ❌ `.env.example` (exemple seulement)
- ❌ `test-form.html` (tests locaux)
- ❌ `test-form.php` (tests locaux)
- ❌ `deploy-to-hostinger.sh` (script local)
- ❌ `README*.md` (documentation)

### Protection du .env:

Ajoutez dans votre `.htaccess` (créez-le dans `/public_html/`):

```apache
# Protéger les fichiers sensibles
<FilesMatch "^\.env">
    Order allow,deny
    Deny from all
</FilesMatch>

# Empêcher l'accès aux dossiers de logs
<DirectoryMatch "logs">
    Order allow,deny
    Deny from all
</DirectoryMatch>
```

## 🐛 Dépannage

### Le formulaire ne s'envoie pas:

1. **Vérifier les logs PHP**:
   - Hostinger: Panneau → Fichiers → Logs PHP
   - Chercher les erreurs dans `/logs/error_log`

2. **Vérifier les permissions**:
   ```bash
   ls -la scan_requests/
   ls -la logs/
   ```

3. **Tester le PHP**:
   Créez `info.php`:
   ```php
   <?php phpinfo(); ?>
   ```
   Visitez `https://www.xeops.ai/info.php`
   Vérifiez: Version PHP, mail() function, cURL, JSON

### Les emails ne sont pas envoyés:

1. **Vérifier le .env**:
   - Les identifiants SMTP sont-ils corrects?
   - Le fichier .env existe-t-il?
   - Le fichier .env est-il lisible par PHP?

2. **Tester avec test-email.php** (voir section Test ci-dessus)

3. **Vérifier les logs**:
   ```bash
   cat logs/form_submissions.log
   ```

### Erreur 500:

1. Vérifier la version PHP (doit être 7.4+)
2. Vérifier la syntaxe PHP: `php -l form-submit.php`
3. Vérifier les logs d'erreur du serveur

## 📊 Monitoring

### Vérifier les soumissions:

```bash
# Via SSH ou FTP
ls -lh scan_requests/
tail -n 20 logs/form_submissions.log
```

### Exporter les données pour CRM:

Les données sont automatiquement exportées en:
- **JSON**: `/scan_requests/scan_request_*.json` (données complètes)
- **CSV**: `/scan_requests/crm_import_*.csv` (import CRM)

## 🔄 Mise à jour

Pour mettre à jour le site:

```bash
# Option 1: Utiliser le script
./deploy-to-hostinger.sh

# Option 2: Upload manuel via FTP
# Uploadez uniquement les fichiers modifiés
```

## 📞 Support

Si vous rencontrez des problèmes:

1. Vérifiez les logs: `/logs/form_submissions.log`
2. Vérifiez les permissions des dossiers
3. Testez avec des données de test
4. Contactez le support Hostinger si problème serveur

## 🎉 C'est tout !

Votre formulaire de scan gratuit est maintenant en production et prêt à recevoir des demandes clients !

**URL du formulaire**: https://www.xeops.ai/free-scan-form.html

---

**Date de création**: 2025-01-10
**Version**: 1.0
**Auteur**: XeOps.ai Team
