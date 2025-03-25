<?php
$host = "localhost";
$username = "root";  // Change if needed
$password = "";  // Change if needed
$database = "readybasket_1";

// Create a connection
$conn = new mysqli($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
