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

// Read input data
$data = json_decode(file_get_contents("php://input"), true);

// Check for required field: name
if (!isset($data['name']) || empty($data['name'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Product name is required']);
    exit;
}

$product_name = trim($data['name']);

// Validate product name
if (empty($product_name)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Product name cannot be empty']);
    exit;
}

try {
    // Fetch the product by name (case-insensitive)
    $sql = "SELECT id, image_path FROM products WHERE LOWER(name) = LOWER(:name) LIMIT 1";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([':name' => $product_name]);
    $product = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($product) {
        // Delete the image file if it exists
        if ($product['image_path'] && file_exists($product['image_path'])) {
            error_log('Deleting image: ' . $product['image_path']);
            unlink($product['image_path']);
        } else {
            error_log('Image file not found: ' . $product['image_path']);
        }

        // Delete the product from the database
        $sql = "DELETE FROM products WHERE id = :id";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([':id' => $product['id']]);

        if ($stmt->rowCount() > 0) {
            http_response_code(200);
            echo json_encode(['success' => true, 'message' => 'Product deleted successfully']);
        } else {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to delete product']);
        }
    } else {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Product not found']);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed to delete product: ' . $e->getMessage()]);
    error_log('Delete error: ' . $e->getMessage());
}
?>