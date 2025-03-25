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

// Check for required fields (excluding 'id' since we're using 'name')
if (!isset($_POST['name']) || !isset($_POST['price']) ||
    !isset($_POST['old_price']) || !isset($_POST['stock']) || 
    !isset($_POST['quantity']) || !isset($_POST['category'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'All fields are required']);
    exit;
}

$product_name = trim($_POST['name']);
$price = floatval($_POST['price']);
$old_price = floatval($_POST['old_price']);
$stock = intval($_POST['stock']);
$quantity = trim($_POST['quantity']);
$category = trim($_POST['category']);

// Validate inputs
if (empty($product_name)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Product name cannot be empty']);
    exit;
}

if ($price <= 0 || $old_price < 0 || $stock < 0 || empty($quantity) || empty($category)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid product details']);
    exit;
}

try {
    // Fetch existing product by name (case-insensitive)
    $sql = "SELECT id, image_path FROM products WHERE LOWER(name) = LOWER(:name) LIMIT 1";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([':name' => $product_name]);
    $product = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$product) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Product not found']);
        exit;
    }

    $product_id = $product['id'];
    $imagePath = $product['image_path'];

    // Handle image upload if a new image is provided
    if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
        $image = $_FILES['image'];
        $imageName = time() . '_' . basename($image['name']);
        $uploadDir = 'uploads/';
        $newImagePath = $uploadDir . $imageName;

        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        if (move_uploaded_file($image['tmp_name'], $newImagePath)) {
            if ($imagePath && file_exists($imagePath)) {
                unlink($imagePath); // Delete old image
            }
            $imagePath = $newImagePath;
        } else {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to upload new image']);
            exit;
        }
    }

    // Update the product in the database
    $sql = "UPDATE products SET 
            name = :name, 
            price = :price, 
            old_price = :old_price, 
            stock = :stock, 
            quantity = :quantity, 
            category = :category, 
            image_path = :image_path 
            WHERE id = :id";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ':id' => $product_id,
        ':name' => $product_name,
        ':price' => $price,
        ':old_price' => $old_price,
        ':stock' => $stock,
        ':quantity' => $quantity,
        ':category' => $category,
        ':image_path' => $imagePath,
    ]);

    http_response_code(200);
    echo json_encode(['success' => true, 'message' => 'Product updated successfully']);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>