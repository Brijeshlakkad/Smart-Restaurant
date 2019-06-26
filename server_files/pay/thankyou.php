<?php
include 'Instamojo.php';
$api = new Instamojo\Instamojo('test_d118b5d272125f178d199f2f534', 'test_2c6a1c67738201f4e677b88dd6a','https://test.instamojo.com/api/1.1/');
$payid = $_GET["payment_request_id"];
try {
$response = $api->paymentRequestStatus($payid);
echo "<h4>Payment ID: " . $response['payments'][0]['payment_id'] . "</h4>" ;
echo "<h4>Payment Name: " . $response['payments'][0]['buyer_name'] . "</h4>" ;
echo "<h4>Payment Email: " . $response['payments'][0]['buyer'] . "</h4>" ;
echo "<h4>Amount: " . $response['payments'][0]['amount'] . "</h4>" ;
}
catch (Exception $e) {
print('Error: ' . $e->getMessage());
}
?>
