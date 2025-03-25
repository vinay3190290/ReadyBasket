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
$payment_id = $data['payment_id'] ?? '';
$customer_name = $data['customer_name'] ?? '';
$email = $data['email'] ?? '';
$mobile = $data['mobile'] ?? '';
$total = $data['total'] ?? 0.0;
$items = $data['items'] ?? [];

if (empty($payment_id) || empty($customer_name) || empty($mobile) || empty($items)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Required fields are missing']);
    exit;
}

// Log incoming items for debugging
error_log('Items received: ' . print_r($items, true));

// Start transaction
$pdo->beginTransaction();

try {
    // Use first item's old_price and image for the orders table
    $firstItem = !empty($items) ? $items[0] : [];
    $old_price = isset($firstItem['old_price']) ? floatval($firstItem['old_price']) : 0.0;
    $image = $firstItem['image'] ?? '';

    // Insert into orders table with old_price and image
    $sql = "INSERT INTO orders (payment_id, customer_name, email, mobile, total, old_price) 
            VALUES (:payment_id, :customer_name, :email, :mobile, :total, :old_price)";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ':payment_id' => $payment_id,
        ':customer_name' => $customer_name,
        ':email' => $email,
        ':mobile' => $mobile,
        ':total' => $total,
        ':old_price' => $old_price,
    ]);
    $order_id = $pdo->lastInsertId();

    // Insert into order_items table with old_price and image
    $sql = "INSERT INTO order_items (order_id, product_name, price, old_price, quantity, image) 
            VALUES (:order_id, :product_name, :price, :old_price, :quantity, :image)";
    $stmt = $pdo->prepare($sql);

    foreach ($items as $item) {
        error_log('Inserting item: ' . print_r($item, true));
        $stmt->execute([
            ':order_id' => $order_id,
            ':product_name' => $item['name'],
            ':price' => $item['price'],
            ':old_price' => isset($item['old_price']) ? floatval($item['old_price']) : 0.0,
            ':quantity' => $item['quantity'],
            ':image' => $item['image'] ?? '',
        ]);
    }

    // Commit transaction
    $pdo->commit();
    http_response_code(200);
    echo json_encode(['success' => true, 'message' => 'Order saved successfully']);
} catch (PDOException $e) {
    $pdo->rollBack();
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed to save order: ' . $e->getMessage()]);
}
?>