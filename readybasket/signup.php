<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization");

// Database connection
$host = "localhost";
$dbname = "readybasket_1";
$username = "root";  // Change if using a different MySQL user
$password = "";      // Change if you have a MySQL password

$conn = new mysqli($host, $username, $password, $dbname);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit();
}

// Read input data
$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['mobile_number']) || empty($data['mobile_number'])) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Mobile number is required"]);
    exit();
}

$mobile_number = trim($data['mobile_number']);

// Validate mobile number (must be exactly 10 digits and numeric)
if (!preg_match('/^\d{10}$/', $mobile_number)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Invalid mobile number. Must be 10 digits."]);
    exit();
}

// Check if the mobile number already exists
$sql = "SELECT id FROM users WHERE mobile_number = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $mobile_number);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows > 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Mobile number already registered"]);
    $stmt->close();
    $conn->close();
    exit();
}
$stmt->close();

// Insert new user with timestamp, name, and email
$timestamp = date("Y-m-d H:i:s"); // Current timestamp
$default_name = "User"; // Default name
$default_email = ""; // Default email
$insert_sql = "INSERT INTO users (mobile_number, name, email, created_at) VALUES (?, ?, ?, ?)";
$stmt = $conn->prepare($insert_sql);
$stmt->bind_param("ssss", $mobile_number, $default_name, $default_email, $timestamp);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Signup successful",
        "user" => [
            "name" => $default_name,
            "email" => $default_email,
            "mobile_number" => $mobile_number
        ]
    ]);
} else {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Error signing up"]);
}

$stmt->close();
$conn->close();
?>