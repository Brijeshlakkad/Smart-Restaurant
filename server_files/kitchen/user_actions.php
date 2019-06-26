<?php
require_once("../config.php");
require_once("user_data.php");
function getUserDetails($gotData){
  $email=$gotData->email;
  $u=getUserDataUsingEmail($gotData->con,$email);
  if($u->error) return $u;
  $gotData->user=(object) null;
  $gotData->user=$u;
  return $gotData;
}
function updateUserDetails($gotData){
  $email=$gotData->user->email;
  $name=$gotData->user->name;
  $city=$gotData->user->city;
  $mobile=$gotData->user->mobile;
  $address=$gotData->user->address;
  $sql="UPDATE user SET name='$name',city='$city',mobile='$mobile',address='$address' WHERE email='$email'";
  $result=mysqli_query($gotData->con,$sql);
  if($result && (mysqli_affected_rows($gotData->con)==1)){
    $gotData->email=$email;
    $gotData=getUserDetails($gotData);
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Try again!";
  return $gotData;
}
function changePassword($gotData){
  $email=$gotData->user->email;
  $oldPassword= $gotData->user->oldPassword;
  $newPassword= $gotData->user->newPassword;
  $u=getUserDataUsingEmail($gotData->con,$email);
  if($u->error) return $u;
  if($oldPassword!=$u->password){
      $gotData->error=true;
      $gotData->errorMessage="Old Password is not correct.";
      return $gotData;
  }
  $sql="UPDATE user SET password='$newPassword' WHERE email='$email'";
  $result=mysqli_query($gotData->con,$sql);
  if($result && (mysqli_affected_rows($gotData->con)==1)){
    $gotData->user=$u;
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Try again!";
  return $gotData;
}
$gotData=(object) null;
if(isset($_REQUEST['action'])){
  $action=$_REQUEST['action'];
  $gotData->con=$con;
  $gotData->error=false;
  $gotData->errorMessage=null;
  if($action==1 && isset($_REQUEST['email']))
  {
    $email=$_REQUEST['email'];
    $gotData->email=$email;
    $gotData=getUserDetails($gotData);
    $gotData->con=(object) null;
    echo json_encode($gotData);
    exit();
  }else if($action==2 && isset($_REQUEST['email']) && isset($_REQUEST['city']) && isset($_REQUEST['mobile']) && isset($_REQUEST['name'])  && isset($_REQUEST['address'])){
    $gotData->user=(object) null;
    $gotData->user->email=$_REQUEST['email'];
    $gotData->user->name=ucfirst($_REQUEST['name']);
    $gotData->user->city=ucfirst($_REQUEST['city']);
    $gotData->user->mobile=$_REQUEST['mobile'];
    $gotData->user->address=$_REQUEST['address'];
    $gotData=updateUserDetails($gotData);
    $gotData->con=(object) null;
    echo json_encode($gotData);
    exit();
  }else if($action==3 && isset($_REQUEST['email'])  && isset($_REQUEST['oldPassword'])  && isset($_REQUEST['newPassword'])){
    $gotData->user=(object) null;
    $gotData->user->email=$_REQUEST['email'];
    $gotData->user->oldPassword=$_REQUEST['oldPassword'];
    $gotData->user->newPassword=$_REQUEST['newPassword'];
    $gotData=changePassword($gotData);
    $gotData->con=(object) null;
    echo json_encode($gotData);
    exit();
  }else{
    $gotData->error=true;
    $gotData->errorMessage="Try again!";
    $gotData->con=(object) null;
    echo json_encode($gotData);
    exit();
  }
}else{
  $gotData->error=true;
  $gotData->errorMessage="Try again!";
  $gotData->con=(object) null;
  echo json_encode($gotData);
  exit();
}
?>
