<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
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

// Get POST data
$data = json_decode(file_get_contents("php://input"), true);
$name = $data['name'] ?? '';
$email = $data['email'] ?? '';
$mobile = $data['mobile'] ?? '';

if (empty($name) || empty($email) || empty($mobile)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'All fields are required']);
    exit;
}

// Check if user exists (assuming mobile is unique identifier)
$sql = "SELECT COUNT(*) FROM profiles WHERE mobile = :mobile";
$stmt = $pdo->prepare($sql);
$stmt->execute([':mobile' => $mobile]);
$exists = $stmt->fetchColumn();

if ($exists) {
    // Update existing profile
    $sql = "UPDATE profiles SET name = :name, email = :email WHERE mobile = :mobile";
} else {
    // Insert new profile
    $sql = "INSERT INTO profiles (name, email, mobile) VALUES (:name, :email, :mobile)";
}

try {
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ':name' => $name,
        ':email' => $email,
        ':mobile' => $mobile,
    ]);
    http_response_code(200);
    echo json_encode(['success' => true, 'message' => 'Profile saved successfully']);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Query failed: ' . $e->getMessage()]);
}
?>