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
    $gotData->b=$type;
    if(trim($type)==trim($row['type'])){
        return $gotData;
    }
    $gotData->user=(object) null;
  }
  $gotData->error=true;
  $gotData->errorMessage="Email or Password is wrong!";
  return $gotData;
}
if(isset($_REQUEST['email']) && isset($_REQUEST['password']) && isset($_REQUEST['type']))
{
  $email=$_REQUEST['email'];
  $password=$_REQUEST['password'];
  $type=$_REQUEST['type'];
  $gotData=(object) null;
  $gotData->error=false;
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
