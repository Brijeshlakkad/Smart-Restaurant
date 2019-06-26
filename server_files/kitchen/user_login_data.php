<?php
require_once("../config.php");
function checkUser($email,$password,$type,$gotData){
  $sql="SELECT * FROM user where email='$email' AND pass='$password'";
  $result=mysqli_query($gotData->con,$sql);
  if($result && (mysqli_num_rows($result)==1))
  {
    $gotData->error=false;
    $gotData->user=(object) null;
    $row=mysqli_fetch_array($result);
    $gotData->user->id=$row['id'];
    $gotData->user->email=$row['email'];
    $gotData->user->name=$row['name'];
    $gotData->user->password=$row['pass'];
    $gotData->user->mobile=$row['mobile'];
    $gotData->user->type=$row['type'];
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="User does not exist!";
  return $gotData;
}
if(isset($_REQUEST['email']) && isset($_REQUEST['password']))
{
  $email=$_REQUEST['email'];
  $password=$_REQUEST['password'];
  $gotData=(object) null;
  $gotData->con=$con;
  $gotData=checkUser($email,$password,$type,$gotData);
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
