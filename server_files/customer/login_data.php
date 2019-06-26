<?php
require_once("../config.php");
function checkUser($email,$password,$gotData){
  $sql="SELECT * FROM customer where email='$email' and password='$password'";
  $result=mysqli_query($gotData->con,$sql);
  if($result && (mysqli_num_rows($result)==1))
  {
    $gotData->error=false;
    $gotData->user=(object) null;
    $row=mysqli_fetch_array($result);
    $gotData->user->id=$row['id'];
    $gotData->user->email=$row['email'];
    $gotData->user->name=$row['name'];
    $gotData->user->password=$row['password'];
    $gotData->user->address=$row['address'];
    $gotData->user->mobile=$row['mobile'];
    $gotData->user->city=$row['city'];
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Email or Password is wrong!";
  return $gotData;
}
if(isset($_REQUEST['email']) && isset($_REQUEST['password']))
{
  $email=$_REQUEST['email'];
  $password=$_REQUEST['password'];
  $gotData=(object) null;
  $gotData->con=$con;
  $gotData=checkUser($email,$password,$gotData);
  $gotData->con=(object) null;
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
