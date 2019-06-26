<?php
define('DB_HOST','localhost');
define('DB_NAME','smart_restaurant');
define('DB_USER','smartrestaurant');
define('DB_PASSWORD','smartrestaurant');
global $con;
$con=new mysqli(DB_HOST,DB_USER,DB_PASSWORD,DB_NAME);
if(mysqli_connect_error())
{
  printf("Connection failed: %s\n",mysqli_connect_error());
  exit();
}
?>
