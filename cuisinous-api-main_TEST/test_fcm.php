<?php

require __DIR__ . '/vendor/autoload.php';

use Symfony\Component\Dotenv\Dotenv;
use Symfony\Component\HttpClient\HttpClient;

(new Dotenv())->bootEnv(__DIR__ . '/.env');

$deviceToken   = "eyC16SxvS3yKl5Ca4E0dXt:APA91bEZMEZ_WmYgVzIcHtKT6CIsBVuHXSOvFf1soGTYD0ZRqE6IB9DCtfbktKBmSgfpHCccscxHJxOiLsJ0zX_ArD0YAuoux1qNamf6rLtbvzL_yeslHMU";
$projectId     = $_ENV['FIREBASE_PROJECT_ID'] ?? 'cuisinous-f3c9a';
$credPath      = __DIR__ . '/' . ($_ENV['FIREBASE_CREDENTIALS_PATH'] ?? 'config/firebase/service-account.json');

echo "Project: $projectId\n";
echo "Creds:   $credPath\n";
echo "Token:   " . substr($deviceToken, 0, 30) . "...\n\n";

// --- Load service account JSON ---
$sa = json_decode(file_get_contents($credPath), true);
if (!$sa || !isset($sa['private_key'])) {
    echo "❌ Could not read service account JSON at: $credPath\n";
    exit(1);
}

// --- Helper: base64url encode ---
function base64url(string $data): string {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

// --- Build JWT manually with -5min clock skew offset ---
// Google requires iat to be within ±5 min of their server time.
// If your local clock is ahead, subtract 5 minutes to be safe.
$now = time() - 300; // 5-minute offset back
$header  = base64url(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
$payload = base64url(json_encode([
    'iss'   => $sa['client_email'],
    'sub'   => $sa['client_email'],
    'aud'   => 'https://oauth2.googleapis.com/token',
    'iat'   => $now,
    'exp'   => $now + 3600,
    'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
]));

$signingInput = "$header.$payload";
$privateKey   = openssl_pkey_get_private($sa['private_key']);
openssl_sign($signingInput, $signature, $privateKey, 'sha256WithRSAEncryption');
$jwt = "$signingInput." . base64url($signature);

echo "✅ JWT built. Fetching access token...\n";

// --- Exchange JWT for access token ---
$httpClient = HttpClient::create(['verify_peer' => true, 'verify_host' => true]);

$tokenResponse = $httpClient->request('POST', 'https://oauth2.googleapis.com/token', [
    'body' => [
        'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion'  => $jwt,
    ],
]);

$tokenBody = $tokenResponse->toArray(false);
if (empty($tokenBody['access_token'])) {
    echo "❌ Failed to get access token:\n";
    print_r($tokenBody);
    exit(1);
}
$accessToken = $tokenBody['access_token'];
echo "✅ Got access token.\n";

// --- Send FCM notification ---
$url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";
$response = $httpClient->request('POST', $url, [
    'auth_bearer' => $accessToken,
    'json' => [
        'message' => [
            'token' => $deviceToken,
            'notification' => [
                'title' => 'Cuisinous Test 🔔',
                'body'  => 'FCM is working! This is a test notification.',
            ],
            'data' => ['key' => 'test-order-id'],
        ],
    ],
]);

$status = $response->getStatusCode();
$body   = $response->getContent(false);

if ($status === 200) {
    echo "✅ Notification sent successfully!\n";
    echo "Check your phone/emulator now.\n";
} else {
    echo "❌ FCM returned HTTP $status\n";
    echo $body . "\n";
    file_put_contents(__DIR__ . '/fcm_debug.json', $body);
    echo "Details written to fcm_debug.json\n";
}
