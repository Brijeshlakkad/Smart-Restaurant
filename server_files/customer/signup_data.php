<?php
require_once("../config.php");
function checkEmailExists($gotData){
  $email=$gotData->user->email;
  $sql="SELECT * FROM customer WHERE email='$email'";
  $result=mysqli_query($gotData->con,$sql);
  if($result && (mysqli_num_rows($result)==0)){
    return $gotData;
  }else if(mysqli_num_rows($result)>0){
    $gotData->error=true;
    $gotData->errorMessage="Email is already registered with us.";
    $gotData->field="email";
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Try again!";
  return $gotData;
}
function checkMobileExists($gotData){
  $mobile=$gotData->user->mobile;
  $sql="SELECT * FROM customer WHERE mobile='$mobile'";
  $result=mysqli_query($gotData->con,$sql);
  if($result && (mysqli_num_rows($result)==0)){
    return $gotData;
  }else if(mysqli_num_rows($result)>0){
    $gotData->error=true;
    $gotData->errorMessage="Mobile is already registered with us.";
    $gotData->field="mobile";
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Try again!";
  return $gotData;
}
function create_user($gotData){
  $gotData=checkEmailExists($gotData);
  if($gotData->error) return $gotData;
  $gotData=checkMobileExists($gotData);
  if($gotData->error) return $gotData;
  $name=$gotData->user->name;
  $email=$gotData->user->email;
  $password=$gotData->user->password;
  $address=$gotData->user->address;
  $city=$gotData->user->city;
  $mobile=$gotData->user->mobile;
  $sql="INSERT INTO customer(name,email,password,address,city,mobile) VALUES('$name','$email','$password','$address','$city','$mobile')";
  $result=mysqli_query($gotData->con,$sql);
  if($result)
  {
    $gotData->error=false;
    $gotData->errorMessage=null;
    $gotData->responseMessage="Registration Success";
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Try again!";
  return $gotData;
}
if(isset($_REQUEST['name']) && isset($_REQUEST['email']) && isset($_REQUEST['password']) && isset($_REQUEST['address']) && isset($_REQUEST['city']) && isset($_REQUEST['mobile']))
{
  $name=$_REQUEST['name'];
  $email=$_REQUEST['email'];
  $password=$_REQUEST['password'];
  $address=$_REQUEST['address'];
  $city=$_REQUEST['city'];
  $mobile=$_REQUEST['mobile'];
  $gotData=(object) null;
  $gotData->con=(object) null;
  $gotData->user=(object) null;
  $gotData->error=false;
  $gotData->errorMessage=null;
  $gotData->con=$con;
  $gotData->user->name=ucfirst($name);
  $gotData->user->email=$email;
  $gotData->user->password=$password;
  $gotData->user->address=$address;
  $gotData->user->city=ucfirst($city);
  $gotData->user->mobile=$mobile;
  $gotData=create_user($gotData);
  $gotData->con=null;
  echo json_encode($gotData);
}
else{
  $gotData = (object) null;
  $gotData->error=true;
  $gotData->errorMessage="Try again!";
  $gotData->con=(object) null;
  echo json_encode($gotData);
  exit();
}
?>
