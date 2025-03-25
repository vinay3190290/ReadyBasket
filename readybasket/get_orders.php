<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
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

// Determine the request method and get the mobile number
$method = $_SERVER['REQUEST_METHOD'];
$mobile = '';

if ($method === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);
    $mobile = isset($data['mobile']) ? trim($data['mobile']) : '';
} elseif ($method === 'GET') {
    $mobile = isset($_GET['mobile']) ? trim($_GET['mobile']) : '';
}

// Validate mobile number if provided
if (!empty($mobile) && !preg_match('/^\d{10}$/', $mobile)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid mobile number. Must be 10 digits.']);
    exit;
}

try {
    // Base query to fetch orders
    $sql = "SELECT o.id, o.payment_id, o.customer_name, o.email, o.mobile, o.total, o.old_price, o.created_at, o.image 
            FROM orders o";
    $param = [];

    // Filter by mobile number if provided (for customer view)
    if (!empty($mobile)) {
        $sql .= " WHERE o.mobile = :mobile";
        $param = [':mobile' => $mobile];
    }

    // Add ordering by creation date
    $sql .= " ORDER BY o.created_at DESC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute($param);
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Fetch order items for each order
    $result = [];
    foreach ($orders as &$order) {
        $orderId = $order['id'];
        $sql = "SELECT product_name AS name, price, old_price, quantity, image 
                FROM order_items 
                WHERE order_id = :order_id";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([':order_id' => $orderId]);
        $items = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $order['items'] = $items;
        $result[] = $order;
    }

    http_response_code(200);
    echo json_encode(['success' => true, 'orders' => $result]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed to fetch orders: ' . $e->getMessage()]);
}
?>