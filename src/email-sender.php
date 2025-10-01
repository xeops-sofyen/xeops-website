<?php
/**
 * Email sender using SMTP
 * Supports both PHPMailer and native mail() function
 */

require_once __DIR__ . '/config.php';

class EmailSender {
    private $usePhpMailer = false;
    private $mailer = null;

    public function __construct() {
        // Check if PHPMailer is available
        if (class_exists('PHPMailer\PHPMailer\PHPMailer')) {
            $this->usePhpMailer = true;
            $this->initPhpMailer();
        }
    }

    private function initPhpMailer() {
        $this->mailer = new PHPMailer\PHPMailer\PHPMailer(true);

        try {
            // Server settings
            $this->mailer->isSMTP();
            $this->mailer->Host       = SMTP_HOST;
            $this->mailer->SMTPAuth   = true;
            $this->mailer->Username   = SMTP_USER;
            $this->mailer->Password   = SMTP_PASS;
            $this->mailer->SMTPSecure = PHPMailer\PHPMailer\PHPMailer::ENCRYPTION_STARTTLS;
            $this->mailer->Port       = SMTP_PORT;
            $this->mailer->CharSet    = 'UTF-8';

            // From
            $this->mailer->setFrom(SMTP_FROM, SMTP_FROM_NAME);
        } catch (Exception $e) {
            error_log("PHPMailer initialization failed: " . $e->getMessage());
            $this->usePhpMailer = false;
        }
    }

    public function send($to, $subject, $body, $replyTo = null) {
        if ($this->usePhpMailer) {
            return $this->sendWithPhpMailer($to, $subject, $body, $replyTo);
        } else {
            return $this->sendWithMail($to, $subject, $body, $replyTo);
        }
    }

    private function sendWithPhpMailer($to, $subject, $body, $replyTo = null) {
        try {
            $this->mailer->clearAddresses();
            $this->mailer->clearReplyTos();

            $this->mailer->addAddress($to);
            if ($replyTo) {
                $this->mailer->addReplyTo($replyTo);
            }

            $this->mailer->Subject = $subject;
            $this->mailer->Body    = $body;

            $this->mailer->send();
            return true;
        } catch (Exception $e) {
            error_log("PHPMailer send failed: " . $e->getMessage());
            return false;
        }
    }

    private function sendWithMail($to, $subject, $body, $replyTo = null) {
        $headers = "From: " . SMTP_FROM_NAME . " <" . SMTP_FROM . ">\r\n";

        if ($replyTo) {
            $headers .= "Reply-To: {$replyTo}\r\n";
        }

        $headers .= "Content-Type: text/plain; charset=UTF-8\r\n";
        $headers .= "X-Mailer: PHP/" . phpversion() . "\r\n";

        $result = mail($to, $subject, $body, $headers);

        if (!$result) {
            error_log("mail() function failed for: $to");
        }

        return $result;
    }

    public function sendNotificationEmail($data) {
        $subject = "Nouvelle demande de scan - " . $data['scanId'];

        $message = "
Nouvelle demande de scan de sécurité reçue!

=== INFORMATIONS CLIENT ===
Nom: {$data['firstName']} {$data['lastName']}
Email: {$data['email']}
Téléphone: {$data['phone']}
Poste: {$data['jobTitle']}

=== ENTREPRISE ===
Société: {$data['company']}
Taille: {$data['companySize']}
Secteur: {$data['industry']}

=== SCAN ===
ID: {$data['scanId']}
Urgence: {$data['urgency']}
Infrastructure: " . implode(', ', $data['infrastructure']) . "

=== DÉFIS ===
{$data['challenges']}

=== CONSENTEMENTS ===
GDPR: " . ($data['gdprConsent'] ? 'Oui' : 'Non') . "
Marketing: " . ($data['marketingConsent'] ? 'Oui' : 'Non') . "

=== MÉTADONNÉES ===
IP: {$data['serverMetadata']['ipAddress']}
Date: {$data['serverMetadata']['timestamp']}
User Agent: {$data['serverMetadata']['userAgent']}
";

        return $this->send(EMAIL_TO, $subject, $message, $data['email']);
    }

    public function sendConfirmationEmail($data) {
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

---
contact@xeops.ai
https://xeops.ai
";

        return $this->send($data['email'], $subject, $message);
    }
}
?>
