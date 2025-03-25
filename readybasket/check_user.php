<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "readybasket_1";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit();
}

$jsonInput = file_get_contents("php://input");
$data = json_decode($jsonInput, true);

if (!$data) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Invalid JSON format"]);
    exit();
}

if (!isset($data["mobile_number"]) || empty($data["mobile_number"])) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Mobile number is required"]);
    exit();
}

$mobile = $data["mobile_number"];

// Validate that mobile number is exactly 10 digits
if (!preg_match('/^[0-9]{10}$/', $mobile)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Invalid mobile number. Must be exactly 10 digits."]);
    exit();
}

// Use prepared statements to prevent SQL injection
$stmt = $conn->prepare("SELECT * FROM users WHERE mobile_number = ?");
$stmt->bind_param("s", $mobile);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    echo json_encode([
        "status" => "success",
        "message" => "Login successful",
        "user" => [
            "name" => $user['name'] ?? "User",
            "email" => $user['email'] ?? "",
            "mobile_number" => $user['mobile_number']
        ]
    ]);
} else {
    http_response_code(404);
    echo json_encode(["status" => "error", "message" => "Mobile number not found. Please sign up"]);
}

$stmt->close();
$conn->close();
?>