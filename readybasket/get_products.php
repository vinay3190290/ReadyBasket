<?php
// Set the content type to JSON
header('Content-Type: application/json');
// Allow cross-origin requests (for testing with Flutter app)
header('Access-Control-Allow-Origin: *');

// Database configuration
$host = "localhost";
$dbname = "readybasket_1";
$username = "root";  // Change if using a different MySQL user
$password = "";      // Change if you have a MySQL password

// Create database connection using PDO
try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $e->getMessage()
    ]);
    exit;
}

// Fetch all products from the database
try {
    $sql = "SELECT name, price, old_price, stock, quantity, category, image_path, created_at FROM products";  
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Return the products as JSON
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'products' => $products
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Query failed: ' . $e->getMessage()
    ]);
}
?>