<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

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
    echo json_encode(['success' => false, 'message' => 'Database connection failed: ' . $e->getMessage()]);
    exit;
}

// Simulate fetching the logged-in user's mobile number
// Replace with actual session/auth logic (e.g., session ID or token)
$loggedInMobile = "1234567890"; // Hardcoded for testing; use session/auth in reality

// Query to fetch user by mobile_number
$sql = "SELECT mobile_number FROM users WHERE mobile_number = :mobile";
$stmt = $pdo->prepare($sql);
$stmt->execute([':mobile' => $loggedInMobile]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if ($user) {
    http_response_code(200);
    echo json_encode(['success' => true, 'mobile_number' => $user['mobile_number']]);
} else {
    http_response_code(404);
    echo json_encode(['success' => false, 'message' => 'User not found']);
}
?>