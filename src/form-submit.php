<?php
/**
 * XeOps.ai Free Scan Form Handler
 * Handles form submission, validation, and data storage for CRM integration
 */

// Enable CORS for development
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Configuration
define('RECAPTCHA_SECRET_KEY', '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe'); // Test key
define('DATA_DIR', './scan_requests/');
define('LOG_FILE', './logs/form_submissions.log');

// Ensure directories exist
if (!file_exists(DATA_DIR)) {
    mkdir(DATA_DIR, 0755, true);
}
if (!file_exists(dirname(LOG_FILE))) {
    mkdir(dirname(LOG_FILE), 0755, true);
}

/**
 * Main form handler
 */
function handleFormSubmission() {
    try {
        // Only accept POST requests
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            throw new Exception('Method not allowed', 405);
        }

        // Get JSON input
        $json = file_get_contents('php://input');
        $data = json_decode($json, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception('Invalid JSON data', 400);
        }

        // Validate required fields
        validateFormData($data);

        // Verify reCAPTCHA
        if (!verifyRecaptcha($data['recaptchaResponse'])) {
            throw new Exception('reCAPTCHA verification failed', 400);
        }

        // Sanitize and process data
        $processedData = processFormData($data);

        // Add server-side metadata
        $processedData['serverMetadata'] = [
            'ipAddress' => getClientIP(),
            'userAgent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
            'timestamp' => date('c'),
            'serverProcessingTime' => microtime(true) - $_SERVER['REQUEST_TIME_FLOAT']
        ];

        // Generate unique scan ID
        $scanId = generateScanId();
        $processedData['scanId'] = $scanId;

        // Save data
        $filename = saveFormData($processedData, $scanId);

        // Log submission
        logSubmission($processedData, $filename);

        // Prepare CRM data
        prepareCRMData($processedData);

        // Send confirmation email (placeholder)
        // sendConfirmationEmail($processedData);

        // Calculate delivery time
        $deliveryTime = calculateDeliveryTime($processedData['urgency']);

        // Return success response
        echo json_encode([
            'success' => true,
            'message' => 'Votre demande de scan a été reçue avec succès!',
            'scanId' => $scanId,
            'estimatedDelivery' => $deliveryTime,
            'filename' => $filename
        ]);

    } catch (Exception $e) {
        http_response_code($e->getCode() ?: 500);
        echo json_encode([
            'success' => false,
            'message' => $e->getMessage(),
            'error_code' => $e->getCode()
        ]);
    }
}

/**
 * Validate form data
 */
function validateFormData($data) {
    $required = ['firstName', 'lastName', 'email', 'company', 'companySize', 'industry'];

    foreach ($required as $field) {
        if (empty($data[$field])) {
            throw new Exception("Field '$field' is required", 400);
        }
    }

    // Validate email
    if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
        throw new Exception('Invalid email address', 400);
    }

    // Validate GDPR consent
    if (!isset($data['gdprConsent']) || !$data['gdprConsent']) {
        throw new Exception('GDPR consent is required', 400);
    }

    // Validate company size
    $validSizes = ['1-10', '11-50', '51-200', '201-1000', '1000+'];
    if (!in_array($data['companySize'], $validSizes)) {
        throw new Exception('Invalid company size', 400);
    }

    // Validate industry
    $validIndustries = ['finance', 'healthcare', 'technology', 'manufacturing', 'retail', 'government', 'education', 'other'];
    if (!in_array($data['industry'], $validIndustries)) {
        throw new Exception('Invalid industry', 400);
    }
}

/**
 * Verify reCAPTCHA
 */
function verifyRecaptcha($response) {
    if (empty($response)) {
        return false;
    }

    $data = [
        'secret' => RECAPTCHA_SECRET_KEY,
        'response' => $response,
        'remoteip' => getClientIP()
    ];

    $options = [
        'http' => [
            'header' => "Content-type: application/x-www-form-urlencoded\r\n",
            'method' => 'POST',
            'content' => http_build_query($data)
        ]
    ];

    $context = stream_context_create($options);
    $result = file_get_contents('https://www.google.com/recaptcha/api/siteverify', false, $context);

    if ($result === false) {
        return false;
    }

    $resultJson = json_decode($result, true);
    return $resultJson['success'] ?? false;
}

/**
 * Process and sanitize form data
 */
function processFormData($data) {
    return [
        // Personal Information
        'firstName' => sanitizeString($data['firstName']),
        'lastName' => sanitizeString($data['lastName']),
        'email' => filter_var($data['email'], FILTER_SANITIZE_EMAIL),
        'company' => sanitizeString($data['company']),
        'jobTitle' => sanitizeString($data['jobTitle'] ?? ''),
        'phone' => sanitizeString($data['phone'] ?? ''),

        // Company Information
        'companySize' => $data['companySize'],
        'industry' => $data['industry'],

        // Infrastructure
        'infrastructure' => array_map('sanitizeString', $data['infrastructure'] ?? []),
        'urgency' => $data['urgency'] ?? 'normal',
        'challenges' => sanitizeString($data['challenges'] ?? ''),

        // Consents
        'gdprConsent' => (bool)$data['gdprConsent'],
        'marketingConsent' => (bool)($data['marketingConsent'] ?? false),

        // Client metadata
        'submissionDate' => $data['submissionDate'] ?? date('c'),
        'sourceUrl' => filter_var($data['sourceUrl'] ?? '', FILTER_SANITIZE_URL),
        'userAgent' => sanitizeString($data['userAgent'] ?? ''),
    ];
}

/**
 * Sanitize string input
 */
function sanitizeString($input) {
    return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
}

/**
 * Get client IP address
 */
function getClientIP() {
    $headers = ['HTTP_X_FORWARDED_FOR', 'HTTP_X_REAL_IP', 'HTTP_CLIENT_IP'];

    foreach ($headers as $header) {
        if (!empty($_SERVER[$header])) {
            $ips = explode(',', $_SERVER[$header]);
            return trim($ips[0]);
        }
    }

    return $_SERVER['REMOTE_ADDR'] ?? 'unknown';
}

/**
 * Generate unique scan ID
 */
function generateScanId() {
    return 'XS-' . strtoupper(base_convert(time(), 10, 36)) . '-' . strtoupper(bin2hex(random_bytes(3)));
}

/**
 * Save form data to file
 */
function saveFormData($data, $scanId) {
    $timestamp = date('Y-m-d_H-i-s');
    $filename = "scan_request_{$scanId}_{$timestamp}.json";
    $filepath = DATA_DIR . $filename;

    $jsonData = json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    if (file_put_contents($filepath, $jsonData) === false) {
        throw new Exception('Failed to save form data', 500);
    }

    // Set appropriate permissions
    chmod($filepath, 0644);

    return $filename;
}

/**
 * Prepare data for CRM import
 */
function prepareCRMData($data) {
    $crmData = [
        'first_name' => $data['firstName'],
        'last_name' => $data['lastName'],
        'email' => $data['email'],
        'company' => $data['company'],
        'job_title' => $data['jobTitle'],
        'phone' => $data['phone'],
        'company_size' => $data['companySize'],
        'industry' => $data['industry'],
        'infrastructure' => implode('; ', $data['infrastructure']),
        'urgency' => $data['urgency'],
        'challenges' => $data['challenges'],
        'gdpr_consent' => $data['gdprConsent'] ? 'Yes' : 'No',
        'marketing_consent' => $data['marketingConsent'] ? 'Yes' : 'No',
        'lead_source' => 'Free Scan Form',
        'submission_date' => $data['submissionDate'],
        'scan_id' => $data['scanId'],
        'ip_address' => $data['serverMetadata']['ipAddress'],
    ];

    // Save as CSV for easy CRM import
    $csvFile = DATA_DIR . 'crm_import_' . date('Y-m-d') . '.csv';
    $isNewFile = !file_exists($csvFile);

    $handle = fopen($csvFile, 'a');

    if ($isNewFile) {
        // Add headers for new file
        fputcsv($handle, array_keys($crmData));
    }

    fputcsv($handle, array_values($crmData));
    fclose($handle);

    return $csvFile;
}

/**
 * Log form submission
 */
function logSubmission($data, $filename) {
    $logEntry = [
        'timestamp' => date('c'),
        'scan_id' => $data['scanId'],
        'email' => $data['email'],
        'company' => $data['company'],
        'filename' => $filename,
        'ip_address' => $data['serverMetadata']['ipAddress'],
        'user_agent' => $data['serverMetadata']['userAgent']
    ];

    $logLine = json_encode($logEntry) . "\n";
    file_put_contents(LOG_FILE, $logLine, FILE_APPEND | LOCK_EX);
}

/**
 * Calculate delivery time based on urgency
 */
function calculateDeliveryTime($urgency) {
    $hours = 48; // Default

    switch ($urgency) {
        case 'critical':
            $hours = 12;
            break;
        case 'urgent':
            $hours = 24;
            break;
    }

    $deliveryTime = new DateTime();
    $deliveryTime->add(new DateInterval("PT{$hours}H"));

    return $deliveryTime->format('d/m/Y H:i');
}

/**
 * Send confirmation email (placeholder)
 */
function sendConfirmationEmail($data) {
    // TODO: Implement email sending
    // This would integrate with your email service (SendGrid, Mailgun, etc.)

    $to = $data['email'];
    $subject = "Confirmation de votre demande de scan - " . $data['scanId'];
    $message = "
    Bonjour {$data['firstName']},

    Votre demande de scan de sécurité a été reçue avec succès.

    Détails:
    - ID de scan: {$data['scanId']}
    - Entreprise: {$data['company']}
    - Urgence: {$data['urgency']}

    Vous recevrez votre rapport dans les délais indiqués.

    Cordialement,
    L'équipe XeOps.ai
    ";

    // mail($to, $subject, $message); // Uncomment when email is configured
}

// Handle the request
handleFormSubmission();
?>