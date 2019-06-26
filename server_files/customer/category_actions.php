<?php
require_once("../config.php");
require_once("user_data.php");

function getCategoryList($gotData){
  $sql="SELECT * FROM category";
  $result = mysqli_query($gotData->con,$sql);
  if($result){
    $gotData->user->totalRows=mysqli_num_rows($result);
    if($gotData->user->totalRows>0){
      $i=0;
      while($row=mysqli_fetch_array($result)){
        $gotData->user->category[$i] = (object) null;
        $gotData->user->category[$i]->id=$row['id'];
        $gotData->user->category[$i]->name=$row['name'];
        $gotData->user->category[$i]->image='http://www.smartrestaurant.ml/server_files/images/categories/'.$row['image'];
        $i++;
      }
    }
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Try again!";
  return $gotData;
}

$gotData=(object) null;
$gotData->error=false;
$gotData->errorMessage=null;
if(isset($_REQUEST['action'])){
  $action = $_REQUEST['action'];
  if($action==1){
    $gotData->con=$con;
    $gotData=getCategoryList($gotData);
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
