<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Database configuration
$host = "localhost";
$dbname = "readybasket_1"; // Match your database name
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

// Check if all required fields are present
if (!isset($_POST['name']) || !isset($_POST['price']) || !isset($_POST['old_price']) ||
    !isset($_POST['stock']) || !isset($_POST['quantity']) || !isset($_POST['category']) ||
    !isset($_FILES['image'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'All fields are required']);
    exit;
}

// Get form data
$name = $_POST['name'];
$price = floatval($_POST['price']);
$old_price = floatval($_POST['old_price']);
$stock = intval($_POST['stock']);
$quantity = $_POST['quantity'];
$category = $_POST['category'];

// Handle image upload
$image = $_FILES['image'];
$imageName = time() . '_' . basename($image['name']);
$uploadDir = 'uploads/';
$uploadPath = $uploadDir . $imageName;

if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true); // Create uploads directory if it doesn’t exist
}

if (move_uploaded_file($image['tmp_name'], $uploadPath)) {
    try {
        // Insert product with timestamp (created_at will use CURRENT_TIMESTAMP by default)
        $sql = "INSERT INTO products (name, price, old_price, stock, quantity, category, image_path, created_at) 
                VALUES (:name, :price, :old_price, :stock, :quantity, :category, :image_path, NOW())";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            ':name' => $name,
            ':price' => $price,
            ':old_price' => $old_price,
            ':stock' => $stock,
            ':quantity' => $quantity,
            ':category' => $category,
            ':image_path' => $uploadPath,
        ]);

        http_response_code(200);
        echo json_encode(['success' => true, 'message' => 'Product added successfully']);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
    }
} else {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed to upload image']);
}
?>