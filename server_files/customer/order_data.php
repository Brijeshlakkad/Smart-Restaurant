<?php
class Order{
  var $id,$userID,$token,$tableBookingID,$date,$status,$error,$errorMessage;
  function getData($con,$sql){
    $check=mysqli_query($con,$sql);
    if($check && (mysqli_num_rows($check)==1))
    {
      $row=mysqli_fetch_array($check);
      $this->id=$row['id'];
      $this->userID=$row['uid'];
      $this->token=$row['token'];
      $this->tableBookingID=$row['table_id'];
      $this->date=$row['date'];
      $this->status=$row['status'];
      $this->error=false;
      $this->errorMessage="null";
    }
    else{
      $this->error=true;
      $this->errorMessage="Order Error!";
    }
  }
}
function getOrderDataUsingToken($con,$token){
  $u = new Order;
  $sql="SELECT * FROM `order` where token='$token'";
  $u->getData($con,$sql);
  return $u;
}
function getOrderDataUsingTableBookingID($con,$tableBookingID){
  $u = new Order;
  $sql="SELECT * FROM `order` where table_id='$tableBookingID'";
  $u->getData($con,$sql);
  return $u;
}
function getOrderDataUsingID($con,$id){
  $u = new Order;
  $sql="SELECT * FROM `order` where id='$id'";
  $u->getData($con,$sql);
  return $u;
}
function deleteOrderByID($con,$orderID){
  $sql="DELETE FROM `order` where id='$orderID'";
  $result=mysqli_query($con,$sql);
  if($result){
    return true;
  }
  return false;
}
?>
