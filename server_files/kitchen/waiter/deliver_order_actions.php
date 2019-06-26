<?php
require_once("../../config.php");
require_once("../user_data.php");
function getOrderToDeliver($gotData,$isToday){
  $userID=$gotData->userID;
  $status=$gotData->status;
  $condition="WHERE `assign_waiter`.`waiter_id`='$userID'";
  if($status=="ALL"){
  }else{
    $condition.=" AND `assign_waiter`.`status`='$status'";
  }
  $sql="SELECT `order`.id as `orderID`,COUNT(`order`.`id`) as `orderNum`, `order`.uid as `userID`, `order`.token as `token`, `order`.table_id as `tableBookingID`,
        `order`.`date` as `orderDate`, `order`.status as `status`,
        `book_table`.table as `tableName`, `time_slot`.slot as `slotName`, `table_booking`.slot_id as `slotID`, `book_table`.id as `tableID`, `table_booking`.`date` as `tableBookingDate`,
        `assign_waiter`.`status` as `waiterStatus`, `assign_waiter`.`date` as `waiterDate`
        FROM `order`
        INNER JOIN `order_inventory` ON `order_inventory`.`oid`=`order`.id
        INNER JOIN `table_booking` ON `table_booking`.id=`order`.table_id
        INNER JOIN `book_table` ON `book_table`.id=`table_booking`.tid
        INNER JOIN `time_slot` ON `time_slot`.id=`table_booking`.slot_id
        INNER JOIN `assign_waiter` ON `assign_waiter`.`order_id`=`order`.`id`
        $condition GROUP BY `order`.id ORDER BY `assign_waiter`.`date` DESC";
  $result=mysqli_query($gotData->con,$sql);
  if($result){
    $got=(object) nul;
    $got->con=$gotData->con;
    $got->user=(object) null;
    $got->user->userID=$userID;
    $i=0;
    while($row=mysqli_fetch_array($result)){
      $date1=strtotime(date('Y-m-d H:i:s'));
      $date2=strtotime($row['waiterDate']);
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
      $gotData->madeOrder[$i]->waiterDate=Date("F d, Y \a\\t h:i A",strtotime($row['waiterDate']));
      $gotData->madeOrder[$i]->status=$row['waiterStatus'];
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
function changeOrderStatus($gotData){
  $userID=$gotData->userID;
  $status=$gotData->status;
  $orderID=$gotData->orderID;
  $sql="UPDATE `assign_waiter` SET status='$status' WHERE order_id='$orderID' AND waiter_id='$userID'";
  $result=mysqli_query($gotData->con,$sql);
  if($result){
    return getOrderToDeliver($gotData,"true");
  }
  $gotData->error=true;
  $gotData->errorMessage="Order can't be processed!";
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
    $gotData=getOrderToDeliver($gotData,$_REQUEST['isToday']);
    $gotData->con=(object) null;
    echo json_encode($gotData);
    exit();
  }else if($action==2 && isset($_REQUEST['userID']) && isset($_REQUEST['orderID'])){
    $gotData->con=$con;
    $gotData->userID=$_REQUEST['userID'];
    $gotData->orderID=$_REQUEST['orderID'];
    $gotData->status="Reached";
    $gotData=changeOrderStatus($gotData);
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
