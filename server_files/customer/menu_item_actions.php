<?php
require_once("../config.php");
require_once("user_data.php");

function getMenuItemList($gotData){
  $cid=$gotData->cid;
  $sql="SELECT * FROM menulist WHERE cid='$cid'";
  $result = mysqli_query($gotData->con,$sql);
  if($result){
    $gotData->user->totalRows=mysqli_num_rows($result);
    if($gotData->user->totalRows>0){
      $i=0;
      while($row=mysqli_fetch_array($result)){
        $gotData->user->menuItem[$i] = (object) null;
        $gotData->user->menuItem[$i]->id=$row['id'];
        $gotData->user->menuItem[$i]->name=$row['name'];
        $gotData->user->menuItem[$i]->cid=$row['cid'];
        $gotData->user->menuItem[$i]->price=$row['price'];
        $gotData->user->menuItem[$i]->description=$row['description'];
        $gotData->user->menuItem[$i]->image='http://www.smartrestaurant.ml/server_files/images/menu_items/'.$row['image'];
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
  if($action==1 && isset($_REQUEST['cid'])){
    $gotData->con=$con;
    $gotData->cid=$_REQUEST['cid'];
    $gotData=getMenuItemList($gotData);
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
