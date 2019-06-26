<?php
require_once("../config.php");
require_once("user_data.php");
require_once("token.php");
require_once("order_data.php");
function makeOrder($gotData){
  $orderList=$gotData->orderList;
  $userID=$gotData->userID;
  $tableBookingID=$gotData->tableBookingID;
  $gotToken=getToken($gotData->con);
  if($gotToken->error) return $gotToken;
  $token = $gotToken->token;
  $sql="INSERT INTO `order`(uid,table_id,token) VALUES('$userID','$tableBookingID','$token')";
  $result=mysqli_query($gotData->con,$sql);
  if($result){
    $order=getOrderDataUsingToken($gotData->con,$token);
    $orderID=$order->id;
    for($i=0;$i<count($orderList);$i++){
      $menuItemID=$orderList[$i]->menuItem->id;
      $quantity=(int)$orderList[$i]->quantity;
      $price=(int)$orderList[$i]->menuItem->price;
      $total=$price*$quantity;
      $sql="INSERT INTO `order_inventory`(`oid`,`pid`,`qty`,`price`,`total`) VALUES('$orderID','$menuItemID','$quantity','$price','$total')";
      $inv=mysqli_query($gotData->con,$sql);
      if(!$inv){
        $got=deleteOrderByID($gotData->con,$orderID);
        $gotData->error=true;
        $gotData->errorMessage="Please select food items again";
        return $gotData;
      }
    }
    $gotData->responseMessage="Your order is placed successfully";
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Try again!";
  return $gotData;
}
function getOrderInventory($gotData){
  $userID=$gotData->userID;
  $sql="SELECT `order`.id as `orderID`,COUNT(`order`.`id`) as `orderNum`, `order`.uid as `userID`, `order`.token as `token`, `order`.table_id as `tableBookingID`,
        `order`.`date` as `orderDate`, `order`.status as `status`,
        `book_table`.table as `tableName`, `time_slot`.slot as `slotName`, `table_booking`.slot_id as `slotID`, `book_table`.id as `tableID`, `table_booking`.`date` as `tableBookingDate`
        FROM `order`
        INNER JOIN `order_inventory` ON `order_inventory`.`oid`=`order`.id
        INNER JOIN `table_booking` ON `table_booking`.id=`order`.table_id
        INNER JOIN `book_table` ON `book_table`.id=`table_booking`.tid
        INNER JOIN `time_slot` ON `time_slot`.id=`table_booking`.slot_id
        WHERE `order`.uid='$userID' GROUP BY `order`.id ORDER BY `order`.`date` DESC";
  $result=mysqli_query($gotData->con,$sql);
  if($result){
    $got=(object) nul;
    $got->con=$gotData->con;
    $got->user=(object) null;
    $got->user->userID=$userID;
    $gotData->totalRows=mysqli_num_rows($result);
    $i=0;
    while($row=mysqli_fetch_array($result)){
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
  if($action==1 && isset($_REQUEST['orderList']) && isset($_REQUEST['userID']) && isset($_REQUEST['tableBookingID'])){
    $gotData->con=$con;
    $gotData->orderList=json_decode($_REQUEST['orderList']);
    $gotData->userID=$_REQUEST['userID'];
    $gotData->tableBookingID=$_REQUEST['tableBookingID'];
    $gotData=makeOrder($gotData);
    $gotData->con=(object) null;
    echo json_encode($gotData);
    exit();
  }else if($action==2 && isset($_REQUEST['userID'])){
    $gotData->con=$con;
    $gotData->userID=$_REQUEST['userID'];
    $gotData=getOrderInventory($gotData);
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
