<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if (!file_exists(__DIR__ . '/dbconfig.php')) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'DB config missing']);
    exit;
}
include_once __DIR__ . '/dbconfig.php';
if (!isset($conn) || !$conn) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Database connection not available']);
    exit;
}

$input = $_POST;
if (empty($input)) {
    $raw = file_get_contents('php://input');
    $json = json_decode($raw, true);
    if (is_array($json)) $input = $json;
}

$username = isset($input['username']) ? trim($input['username']) : '';
$password = isset($input['password']) ? $input['password'] : '';

if ($username === '' || $password === '') {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing username or password']);
    exit;
}

if (strlen($password) < 8) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Password must be at least 8 characters']);
    exit;
}

$hashed = password_hash($password, PASSWORD_DEFAULT);

try {
    $stmt = $conn->prepare("SELECT id FROM users WHERE username = ? LIMIT 1");
    if ($stmt === false) throw new Exception('Prepare failed: ' . $conn->error);
    $stmt->bind_param('s', $username);
    $stmt->execute();
    $res = $stmt->get_result();
    if ($res && $res->num_rows > 0) {
        http_response_code(409);
        echo json_encode(['status' => 'error', 'message' => 'User already exists']);
        $stmt->close();
        exit;
    }
    $stmt->close();

    $stmt = $conn->prepare("INSERT INTO users (username, password) VALUES (?, ?)");
    if ($stmt === false) throw new Exception('Prepare failed: ' . $conn->error);
    $stmt->bind_param('ss', $username, $hashed);
    $stmt->execute();

    if ($stmt->affected_rows > 0) {
        echo json_encode(['status' => 'success', 'message' => 'Registered successfully', 'id' => $stmt->insert_id]);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Registration failed']);
    }
    $stmt->close();
} catch (mysqli_sql_exception $e) {
    error_log('DB error: ' . $e->getMessage());
    if ((int)$e->getCode() === 1062) {
        http_response_code(409);
        echo json_encode(['status' => 'error', 'message' => 'User already exists']);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Database error']);
    }
} catch (Exception $e) {
    error_log('Server error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Server error']);
}
?>
