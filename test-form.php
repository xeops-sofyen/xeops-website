<?php
/**
 * Test script for form submission
 * This simulates a form submission to test email delivery
 */

// Test data
$testData = [
    'firstName' => 'Test',
    'lastName' => 'User',
    'email' => 'test@example.com',
    'company' => 'Test Company Ltd',
    'jobTitle' => 'IT Manager',
    'phone' => '+33 1 23 45 67 89',
    'companySize' => '51-200',
    'industry' => 'technology',
    'infrastructure' => ['cloud', 'on-premise'],
    'urgency' => 'normal',
    'challenges' => 'Nous souhaitons améliorer notre posture de sécurité et identifier les vulnérabilités potentielles.',
    'gdprConsent' => true,
    'marketingConsent' => false,
    'submissionDate' => date('c'),
    'userAgent' => 'Test Script',
    'sourceUrl' => 'http://localhost/test',
    'recaptchaResponse' => '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe' // Test key
];

// Convert to JSON
$jsonData = json_encode($testData);

echo "=== TEST DE SOUMISSION DE FORMULAIRE ===\n\n";
echo "Données de test:\n";
echo json_encode($testData, JSON_PRETTY_PRINT) . "\n\n";

// Initialize cURL
$ch = curl_init('http://localhost/src/form-submit.php');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonData);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Content-Length: ' . strlen($jsonData)
]);

// Execute request
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

// Display results
echo "=== RÉSULTAT ===\n\n";
echo "Code HTTP: $httpCode\n";

if ($error) {
    echo "Erreur cURL: $error\n";
}

if ($response) {
    echo "Réponse:\n";
    $responseData = json_decode($response, true);
    if ($responseData) {
        echo json_encode($responseData, JSON_PRETTY_PRINT) . "\n";
    } else {
        echo $response . "\n";
    }
} else {
    echo "Aucune réponse reçue\n";
}

echo "\n=== INSTRUCTIONS ===\n";
echo "1. Assurez-vous qu'un serveur PHP est en cours d'exécution\n";
echo "2. Vérifiez votre boîte mail contact@xeops.ai\n";
echo "3. Vérifiez les fichiers générés dans src/scan_requests/\n";
echo "4. Consultez les logs dans src/logs/form_submissions.log\n";
?>
