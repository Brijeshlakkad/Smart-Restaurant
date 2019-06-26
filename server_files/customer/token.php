<?php
require_once("../config.php");
function getToken($con){
  $gotData=(object) null;
  $gotData->error=false;
  $sql="SELECT token_no FROM token";
  $result=mysqli_query($con,$sql);
  if($result){
    $row=mysqli_fetch_array($result);
    $currentToken=(int)$row['token_no'];
    $acceptedToken=$currentToken+rand(1,10);
    $sql="UPDATE token SET token_no='$acceptedToken' WHERE id='1'";
    $result=mysqli_query($con,$sql);
    if($result){
      $gotData->token=$acceptedToken;
      return $gotData;
    }
  }
  $gotData->error=true;
  $gotData->errorMessage="Token is unavailable";
  return $gotData;
}
?>
