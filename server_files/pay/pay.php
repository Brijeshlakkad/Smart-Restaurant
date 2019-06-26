<?php
$product_name = "Car Rental";//$_POST["purpose"];
$price ="9";// $_POST["amount"];
$name = "Brijesh Lakkad";//$_POST["buyer_name"];
$phone = "7046167267";//$_POST["phone"];
$email = "brijeshlakkad2@gmail.com";//$_POST["email"];
include 'Instamojo.php';       //Download from website

$api = new Instamojo\Instamojo('test_d118b5d272125f178d199f2f534', 'test_2c6a1c67738201f4e677b88dd6a','https://test.instamojo.com/api/1.1/');
try {
    $response = $api->paymentRequestCreate(array(
        "purpose" => $product_name,
        "amount" => $price,
        "buyer_name" => $name,
        "phone" => $phone,
        "send_email" => true,
        "send_sms" => true,
        "email" => $email,
        'allow_repeated_payments' => false,
        "redirect_url" => "http://www.smartrestaurant.ml/server_files/pay/thankyou.php",
        "webhook" => "http://www.smartrestaurant.ml/server_files/pay/webhook.php"
        ));
    //print_r($response);
    $pay_url = $response['longurl'];

    header("Location: $pay_url");
    exit();
}
catch (Exception $e) {
    print('Error: ' . $e->getMessage());
}
?>
