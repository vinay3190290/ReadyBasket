<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization');

// Database configuration
$host = "localhost";
$dbname = "readybasket_1";
$username = "root";
$password = "";

// Create database connection using PDO
try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Database connection failed: ' . $e->getMessage()]);
    exit;
}

// Read input data
$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['mobile_number']) || empty($data['mobile_number'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Mobile number is required']);
    exit;
}

$mobile_number = trim($data['mobile_number']);

// Validate mobile number (must be exactly 10 digits and numeric)
if (!preg_match('/^\d{10}$/', $mobile_number)) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Invalid mobile number. Must be 10 digits.']);
    exit;
}

// Check if the mobile number already exists
$sql = "SELECT id FROM users WHERE mobile_number = :mobile";
$stmt = $pdo->prepare($sql);
$stmt->execute([':mobile' => $mobile_number]);
$existingUser = $stmt->fetch(PDO::FETCH_ASSOC);

if ($existingUser) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Mobile number already registered']);
    exit;
}

// Insert new user with timestamp
$timestamp = date("Y-m-d H:i:s"); // Current timestamp
$insert_sql = "INSERT INTO users (mobile_number, created_at) VALUES (:mobile, :created_at)";
$stmt = $pdo->prepare($insert_sql);
$stmt->execute([
    ':mobile' => $mobile_number,
    ':created_at' => $timestamp
]);

if ($stmt->rowCount() > 0) {
    http_response_code(200);
    echo json_encode([
        'status' => 'success',
        'message' => 'Signup successful',
        'user' => [
            'mobile_number' => $mobile_number,
            'name' => 'User', // Default value for the app
            'email' => ''     // Default value for the app
        ]
    ]);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Error signing up']);
}
?>