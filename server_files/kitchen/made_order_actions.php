<?php
require_once("../config.php");
require_once("user_data.php");
function getOrderInventory($gotData,$isToday){
  $userID=$gotData->userID;
  $status=$gotData->status;
  $condition="";
  if($status=="ALL"){
    $condition="";
  }else{
    $condition="WHERE `order`.`status`='$status'";
  }
  $sql="SELECT `order`.id as `orderID`,COUNT(`order`.`id`) as `orderNum`, `order`.uid as `userID`, `order`.token as `token`, `order`.table_id as `tableBookingID`,
        `order`.`date` as `orderDate`, `order`.status as `status`,
        `book_table`.table as `tableName`, `time_slot`.slot as `slotName`, `table_booking`.slot_id as `slotID`, `book_table`.id as `tableID`, `table_booking`.`date` as `tableBookingDate`
        FROM `order`
        INNER JOIN `order_inventory` ON `order_inventory`.`oid`=`order`.id
        INNER JOIN `table_booking` ON `table_booking`.id=`order`.table_id
        INNER JOIN `book_table` ON `book_table`.id=`table_booking`.tid
        INNER JOIN `time_slot` ON `time_slot`.id=`table_booking`.slot_id
        $condition GROUP BY `order`.id ORDER BY `order`.`date` DESC";
  $result=mysqli_query($gotData->con,$sql);
  if($result){
    $got=(object) nul;
    $got->con=$gotData->con;
    $got->user=(object) null;
    $got->user->userID=$userID;
    $i=0;
    while($row=mysqli_fetch_array($result)){
      $date1=strtotime(date('Y-m-d H:i:s'));
      $date2=strtotime($row['orderDate']);
      $diff_day=floor(($date1-$date2)/(60*60*24));
      if($isToday=="true" && $diff_day!=0){
        continue;
      }else if($isToday=="false" && $diff_day==0){
        continue;
      }
      $tableBooking=(object) null;
      $tableBooking->id=$row['tableBookingID'];
      $tableBooking->tableName=$row['tableName'];
      $tableBooking->tableID=$row['tableID'];
      $tableBooking->slotID=$row['slotID'];
      $tableBooking->slotName=$row['slotName'];
      $tableBooking->date=$row['tableBookingDate'];
      $tableBooking->day=date("D",strtotime($row['tableBookingDate']));
      $orderID=$row['orderID'];
      $gotData->madeOrder[$i]->tableBooking=$tableBooking;
      $gotData->madeOrder[$i]->id=$row['orderID'];
      $gotData->madeOrder[$i]->token=$row['token'];
      $gotData->madeOrder[$i]->date=Date("F d, Y \a\\t h:i A",strtotime($row['orderDate']));
      $gotData->madeOrder[$i]->status=$row['status'];
      $orderDetails="SELECT `order_inventory`.pid as `menuItemID`, `order_inventory`.qty as `quantity`, `order_inventory`.`price` as `price`, `order_inventory`.`total` as `total`,
                    `menulist`.name as `menuItemName`, `menulist`.image as `menuItemImage`, `menulist`.price as `menuItemPrice`, `menulist`.description as `menuItemDescription`,
                    `category`.id as `categoryID`, `category`.name as `categoryName`, `category`.image as `categoryImage`
                    FROM `order_inventory`
                    INNER JOIN `menulist` ON `menulist`.id=`order_inventory`.pid
                    INNER JOIN `category` ON `category`.id=`menulist`.cid WHERE `order_inventory`.`oid`='$orderID'";
      $orderResult=mysqli_query($gotData->con,$orderDetails);
      if($orderResult){
        $k=0;
        while($rowOrder=mysqli_fetch_array($orderResult)){
          $category=(object) null;
          $category->id=$rowOrder['categoryID'];
          $category->name=$rowOrder['categoryName'];
          $category->image=$rowOrder['categoryImage'];
          $menuItem=(object) null;
          $menuItem->id=$rowOrder['menuItemID'];
          $menuItem->cid=$rowOrder['categoryID'];
          $menuItem->name=$rowOrder['menuItemName'];
          $menuItem->image=$rowOrder['menuItemImage'];
          $menuItem->price=$rowOrder['menuItemPrice'];
          $menuItem->description=$rowOrder['menuItemDescription'];
          $gotData->madeOrder[$i]->orderList[$k]=(object) null;
          $gotData->madeOrder[$i]->orderList[$k]->category=$category;
          $gotData->madeOrder[$i]->orderList[$k]->menuItem=$menuItem;
          $gotData->madeOrder[$i]->orderList[$k]->quantity=$rowOrder['quantity'];
          $k++;
        }
      }
      $i++;
    }
    $gotData->totalRows=$i;
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Try again!";
  return $gotData;
}
function assignWaiter($con,$orderID,$waiterEmail){
  $gotData=(object) null;
  $gotData->error=false;
  $waiter=getUserDataUsingEmail($con,$waiterEmail);
  if($waiter->error) return $waiter;
  $waiterID=$waiter->id;
  $sql="INSERT INTO `assign_waiter`(order_id,waiter_id) VALUES('$orderID','$waiterID')";
  $waiterResult=mysqli_query($con,$sql);
  if($waiterResult){
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Waiter can't be assigned!12";
  return $gotData;
}
function changeOrderStatus($gotData){
  $userID=$gotData->userID;
  $status=$gotData->status;
  $orderID=$gotData->orderID;
  $waiterEmail=$gotData->waiterEmail;
  if($status=="Completed"){
    if($waiterEmail!="null"){
      $got=assignWaiter($gotData->con,$orderID,$waiterEmail);
      if($got->error) return $got;
    }else{
      $gotData->error=true;
      $gotData->errorMessage="Waiter wasn't selected!11";
      return $gotData;
    }
  }
  $sql="UPDATE `order` SET status='$status' WHERE id='$orderID'";
  $result=mysqli_query($gotData->con,$sql);
  if($result){
    return getOrderInventory($gotData,"true");
  }
  $gotData->error=true;
  $gotData->errorMessage="Order can't be processed!";
  return $gotData;
}
function getWaiterList($gotData){
  $userID=$gotData->userID;
  $sql="SELECT * FROM user WHERE type='waiter'";
  $result=mysqli_query($gotData->con,$sql);
  if($result){
    $gotData->totalRows=mysqli_num_rows($result);
    $i=0;
    while($row=mysqli_fetch_array($result)){
      $gotData->waiter[$i]=(object) null;
      $gotData->waiter[$i]->id=$row['id'];
      $gotData->waiter[$i]->name=$row['name'];
      $gotData->waiter[$i]->email=$row['email'];
      $gotData->waiter[$i]->mobile=$row['mobile'];
      $i++;
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
  if($action==1 && isset($_REQUEST['userID']) && isset($_REQUEST['status']) && isset($_REQUEST['isToday'])){
    $gotData->con=$con;
    $gotData->userID=$_REQUEST['userID'];
    $gotData->status=$_REQUEST['status'];
    $gotData=getOrderInventory($gotData,$_REQUEST['isToday']);
    $gotData->con=(object) null;
    echo json_encode($gotData);
    exit();
  }if($action==2 && isset($_REQUEST['userID']) && isset($_REQUEST['status']) && isset($_REQUEST['orderID']) && isset($_REQUEST['waiterEmail'])){
    $gotData->con=$con;
    $gotData->userID=$_REQUEST['userID'];
    $gotData->status=$_REQUEST['status'];
    $gotData->orderID=$_REQUEST['orderID'];
    $gotData->waiterEmail=$_REQUEST['waiterEmail'];
    $gotData=changeOrderStatus($gotData);
    $gotData->con=(object) null;
    echo json_encode($gotData);
    exit();
  }if($action==3 && isset($_REQUEST['userID'])){
    $gotData->con=$con;
    $gotData->userID=$_REQUEST['userID'];
    $gotData=getWaiterList($gotData);
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
