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

if (!isset($data['mobile']) || empty($data['mobile'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Mobile number is required']);
    exit;
}

$mobile_number = trim($data['mobile']);

// Validate mobile number (must be exactly 10 digits and numeric)
if (!preg_match('/^\d{10}$/', $mobile_number) && $mobile_number != "N/A") {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid mobile number. Must be 10 digits.']);
    exit;
}

// If the mobile number is "N/A" (Guest user), return an empty orders list
if ($mobile_number == "N/A") {
    http_response_code(200);
    echo json_encode(['success' => true, 'orders' => []]);
    exit;
}

// Fetch orders for the given mobile number
try {
    $sql = "SELECT id, mobile_number, total, created_at FROM orders WHERE mobile_number = :mobile";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([':mobile' => $mobile_number]);
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $result = [];
    foreach ($orders as $order) {
        // Fetch items for this order
        $items_sql = "SELECT name, price, quantity, old_price, image FROM order_items WHERE order_id = :order_id";
        $items_stmt = $pdo->prepare($items_sql);
        $items_stmt->execute([':order_id' => $order['id']]);
        $items = $items_stmt->fetchAll(PDO::FETCH_ASSOC);

        $result[] = [
            'id' => $order['id'],
            'mobile_number' => $order['mobile_number'],
            'total' => $order['total'],
            'created_at' => $order['created_at'],
            'items' => $items
        ];
    }

    http_response_code(200);
    echo json_encode(['success' => true, 'orders' => $result]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error fetching orders: ' . $e->getMessage()]);
    exit;
}
?>