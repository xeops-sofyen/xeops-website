// Form Handler for XeOps.ai Free Scan
class FreeScanFormHandler {
    constructor() {
        this.form = document.getElementById('freeScanForm');
        this.submitBtn = document.getElementById('submitBtn');
        this.submitText = document.getElementById('submitText');
        this.submitSpinner = document.getElementById('submitSpinner');
        this.alertMessage = document.getElementById('alertMessage');
        this.currentStep = 1;

        this.initializeForm();
    }

    initializeForm() {
        // Add form submission handler
        this.form.addEventListener('submit', (e) => this.handleSubmit(e));

        // Add real-time validation
        this.addRealTimeValidation();

        // Initialize progress tracking
        this.updateProgressSteps();
    }

    addRealTimeValidation() {
        const requiredFields = ['firstName', 'lastName', 'email', 'company', 'companySize', 'industry'];

        requiredFields.forEach(fieldId => {
            const field = document.getElementById(fieldId);
            if (field) {
                field.addEventListener('blur', () => this.validateField(field));
                field.addEventListener('input', () => this.clearFieldError(field));
            }
        });

        // Email validation
        const emailField = document.getElementById('email');
        if (emailField) {
            emailField.addEventListener('input', () => this.validateEmail(emailField));
        }
    }

    validateField(field) {
        const value = field.value.trim();
        const isValid = value.length > 0;

        if (!isValid) {
            this.showFieldError(field, 'Ce champ est requis');
        } else {
            this.clearFieldError(field);
        }

        return isValid;
    }

    validateEmail(field) {
        const email = field.value.trim();
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        const isValid = emailRegex.test(email);

        if (email && !isValid) {
            this.showFieldError(field, 'Veuillez entrer une adresse email valide');
        } else {
            this.clearFieldError(field);
        }

        return isValid;
    }

    showFieldError(field, message) {
        field.classList.add('border-red-500', 'bg-red-50');
        field.classList.remove('border-gray-300');

        // Remove existing error message
        const existingError = field.parentNode.querySelector('.error-message');
        if (existingError) {
            existingError.remove();
        }

        // Add error message
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error-message text-red-500 text-sm mt-1';
        errorDiv.textContent = message;
        field.parentNode.appendChild(errorDiv);
    }

    clearFieldError(field) {
        field.classList.remove('border-red-500', 'bg-red-50');
        field.classList.add('border-gray-300');

        const errorMessage = field.parentNode.querySelector('.error-message');
        if (errorMessage) {
            errorMessage.remove();
        }
    }

    updateProgressSteps() {
        const steps = document.querySelectorAll('.step-indicator');
        const stepTexts = document.querySelectorAll('.step-indicator + span');

        steps.forEach((step, index) => {
            if (index < this.currentStep) {
                step.classList.remove('opacity-50');
                step.classList.add('bg-green-500');
                stepTexts[index].classList.remove('text-gray-400');
                stepTexts[index].classList.add('text-green-600');
            }
        });
    }

    showAlert(message, type = 'info') {
        this.alertMessage.className = `mb-6 p-4 rounded-lg ${this.getAlertClasses(type)}`;
        this.alertMessage.innerHTML = `
            <div class="flex items-center">
                ${this.getAlertIcon(type)}
                <span class="ml-3">${message}</span>
            </div>
        `;
        this.alertMessage.classList.remove('hidden');

        // Auto-hide after 5 seconds for success/info messages
        if (type === 'success' || type === 'info') {
            setTimeout(() => {
                this.alertMessage.classList.add('hidden');
            }, 5000);
        }
    }

    getAlertClasses(type) {
        const classes = {
            'success': 'bg-green-100 border border-green-400 text-green-700',
            'error': 'bg-red-100 border border-red-400 text-red-700',
            'warning': 'bg-yellow-100 border border-yellow-400 text-yellow-700',
            'info': 'bg-blue-100 border border-blue-400 text-blue-700'
        };
        return classes[type] || classes.info;
    }

    getAlertIcon(type) {
        const icons = {
            'success': '<svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path></svg>',
            'error': '<svg class="w-5 h-5 text-red-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path></svg>',
            'warning': '<svg class="w-5 h-5 text-yellow-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path></svg>',
            'info': '<svg class="w-5 h-5 text-blue-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path></svg>'
        };
        return icons[type] || icons.info;
    }

    validateForm() {
        let isValid = true;
        const requiredFields = ['firstName', 'lastName', 'email', 'company', 'companySize', 'industry'];

        // Clear any existing alerts
        this.alertMessage.classList.add('hidden');

        // Validate required fields
        requiredFields.forEach(fieldId => {
            const field = document.getElementById(fieldId);
            if (field && !this.validateField(field)) {
                isValid = false;
            }
        });

        // Validate email format
        const emailField = document.getElementById('email');
        if (emailField && !this.validateEmail(emailField)) {
            isValid = false;
        }

        // Validate GDPR consent
        const gdprConsent = document.getElementById('gdprConsent');
        if (!gdprConsent.checked) {
            this.showAlert('Vous devez accepter le traitement de vos données pour continuer.', 'error');
            isValid = false;
        }

        // Validate reCAPTCHA
        const recaptchaResponse = grecaptcha.getResponse();
        if (!recaptchaResponse) {
            this.showAlert('Veuillez valider le reCAPTCHA.', 'error');
            isValid = false;
        }

        // Validate infrastructure selection
        const infrastructureCheckboxes = document.querySelectorAll('input[name=\"infrastructure\"]:checked');
        if (infrastructureCheckboxes.length === 0) {
            this.showAlert('Veuillez sélectionner au moins un type d\\'infrastructure.', 'warning');
        }

        return isValid;
    }

    collectFormData() {
        const formData = new FormData(this.form);
        const data = {
            // Personal Information
            firstName: formData.get('firstName'),
            lastName: formData.get('lastName'),
            email: formData.get('email'),
            company: formData.get('company'),
            jobTitle: formData.get('jobTitle'),
            phone: formData.get('phone'),

            // Company Information
            companySize: formData.get('companySize'),
            industry: formData.get('industry'),

            // Infrastructure
            infrastructure: formData.getAll('infrastructure'),
            urgency: formData.get('urgency'),
            challenges: formData.get('challenges'),

            // Consents
            gdprConsent: formData.get('gdprConsent') === 'on',
            marketingConsent: formData.get('marketingConsent') === 'on',

            // Metadata
            submissionDate: new Date().toISOString(),
            userAgent: navigator.userAgent,
            sourceUrl: window.location.href,
            ipAddress: null, // Will be filled server-side

            // reCAPTCHA
            recaptchaResponse: grecaptcha.getResponse()
        };

        return data;
    }

    async handleSubmit(event) {
        event.preventDefault();

        // Validate form
        if (!this.validateForm()) {
            return;
        }

        // Show loading state
        this.setLoadingState(true);
        this.currentStep = 2;
        this.updateProgressSteps();

        try {
            // Collect form data
            const formData = this.collectFormData();

            // Save to local storage as backup
            this.saveToLocalStorage(formData);

            // Submit to server
            const response = await this.submitToServer(formData);

            if (response.success) {
                this.currentStep = 3;
                this.updateProgressSteps();
                this.showSuccessMessage(response);

                // Redirect after 3 seconds
                setTimeout(() => {
                    window.location.href = 'xeops_final_site.html?scan=requested';
                }, 3000);
            } else {
                throw new Error(response.message || 'Erreur lors de la soumission');
            }

        } catch (error) {
            this.showAlert(`Erreur: ${error.message}`, 'error');
            this.currentStep = 1;
            this.updateProgressSteps();
        } finally {
            this.setLoadingState(false);
        }
    }

    setLoadingState(loading) {
        if (loading) {
            this.submitBtn.disabled = true;
            this.submitText.textContent = 'Envoi en cours...';
            this.submitSpinner.classList.remove('hidden');
        } else {
            this.submitBtn.disabled = false;
            this.submitText.textContent = 'Lancer le Scan Gratuit';
            this.submitSpinner.classList.add('hidden');
        }
    }

    saveToLocalStorage(data) {
        try {
            const storageKey = `xeops_scan_request_${Date.now()}`;
            localStorage.setItem(storageKey, JSON.stringify(data));
            console.log('Form data saved to localStorage:', storageKey);
        } catch (error) {
            console.warn('Could not save to localStorage:', error);
        }
    }

    async submitToServer(data) {
        // This would normally send to your actual API endpoint
        // For now, we'll simulate the API call and save to a local file

        console.log('Submitting form data:', data);

        // Simulate API call delay
        await new Promise(resolve => setTimeout(resolve, 2000));

        // Save to local file (this would be handled by your actual API)
        await this.saveToLocalFile(data);

        // Simulate successful response
        return {
            success: true,
            message: 'Votre demande de scan a été reçue avec succès!',
            scanId: this.generateScanId(),
            estimatedDelivery: this.calculateDeliveryTime(data.urgency)
        };
    }

    async saveToLocalFile(data) {
        try {
            // Create CSV format for easy CRM import
            const csvData = this.formatForCRM(data);
            const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
            const filename = `xeops_scan_request_${timestamp}.json`;

            // Save as JSON for complete data
            const jsonBlob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });

            // Save as CSV for CRM import
            const csvBlob = new Blob([csvData], { type: 'text/csv' });

            // In a real implementation, this would be sent to your server
            console.log('Data prepared for CRM import:', csvData);
            console.log('Complete form data:', data);

            // You can download the file for testing
            // this.downloadFile(jsonBlob, `${filename}.json`);
            // this.downloadFile(csvBlob, `xeops_leads_${timestamp}.csv`);

        } catch (error) {
            console.error('Error saving data:', error);
            throw error;
        }
    }

    formatForCRM(data) {
        // Format data for CRM import (e.g., HubSpot, Salesforce)
        const csvHeaders = [
            'First Name', 'Last Name', 'Email', 'Company', 'Job Title', 'Phone',
            'Company Size', 'Industry', 'Infrastructure', 'Urgency', 'Challenges',
            'GDPR Consent', 'Marketing Consent', 'Submission Date', 'Source'
        ];

        const csvRow = [
            data.firstName,
            data.lastName,
            data.email,
            data.company,
            data.jobTitle || '',
            data.phone || '',
            data.companySize,
            data.industry,
            data.infrastructure.join('; '),
            data.urgency,
            data.challenges || '',
            data.gdprConsent ? 'Yes' : 'No',
            data.marketingConsent ? 'Yes' : 'No',
            data.submissionDate,
            'Free Scan Form'
        ];

        return csvHeaders.join(',') + '\\n' + csvRow.map(field => `\"${field}\"`).join(',');
    }

    downloadFile(blob, filename) {
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        a.click();
        URL.revokeObjectURL(url);
    }

    generateScanId() {
        return 'XS-' + Date.now().toString(36).toUpperCase() + '-' + Math.random().toString(36).substring(2, 8).toUpperCase();
    }

    calculateDeliveryTime(urgency) {
        const now = new Date();
        let deliveryHours;

        switch (urgency) {
            case 'critical':
                deliveryHours = 12;
                break;
            case 'urgent':
                deliveryHours = 24;
                break;
            default:
                deliveryHours = 48;
        }

        const deliveryDate = new Date(now.getTime() + (deliveryHours * 60 * 60 * 1000));
        return deliveryDate.toLocaleString('fr-FR');
    }

    showSuccessMessage(response) {
        const successHtml = `
            <div class="text-center">
                <div class="success-checkmark w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg class="w-8 h-8 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                    </svg>
                </div>
                <h3 class="text-2xl font-bold text-green-600 mb-2">Demande Envoyée!</h3>
                <p class="text-gray-600 mb-4">${response.message}</p>
                <div class="bg-gray-50 p-4 rounded-lg mb-4">
                    <p><strong>ID de scan:</strong> ${response.scanId}</p>
                    <p><strong>Livraison estimée:</strong> ${response.estimatedDelivery}</p>
                </div>
                <p class="text-sm text-gray-500">Vous allez être redirigé automatiquement...</p>
            </div>
        `;

        // Replace form with success message
        this.form.innerHTML = successHtml;
    }
}

// Initialize form handler when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new FreeScanFormHandler();
});

// Export for potential external use
window.FreeScanFormHandler = FreeScanFormHandler;