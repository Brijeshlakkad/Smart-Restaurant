<?php
require_once("../config.php");
require_once("user_data.php");
// date_default_timezone_set("Asia/Kolkata");
date_default_timezone_set("America/Araguaina");
function availableTableList($gotData,$table,$today){
  $j=0;
  $gotData->user->tableBooking=[];
  for($i=0;$i<count($table);$i++){
    $tableID=$table[$i];
    $sql="SELECT * FROM table_booking WHERE tid='$tableID'";
    $result=mysqli_query($gotData->con,$sql);
    if($result){
      if(mysqli_num_rows($result)>0){
        while($row=mysqli_fetch_array($result)){
          $date=$row['date'];
          $now = new DateTime();
          if($today){
            $date1=strtotime(date('Y-m-d H:i:s'));
            $date2=strtotime($date);
            $diff=floor(($date1-$date2)/(60*60*24));
            if($diff==0){
              if(!in_array($tableID,$gotData->user->tableBooking)){
                $gotData->user->tableBooking[$j]=(object) null;
                $gotData->user->tableBooking[$j]=$row['id'];
                $j++;
              }
            }
          }else{
            $date1=date_create(date('Y-m-d',$now));
            $date2=date_create($date);
            $diff=date_diff($date1,$date2);
            $diff_days = $diff->format("%a");
            if($diff_days>0){
              if(!in_array($tableID,$gotData->user->table)){
                $gotData->user->table[$j]=(object) null;
                $gotData->user->tableBooking[$j]=(object) null;
                $gotData->user->tableBooking[$j]=$row['id'];
                $gotData->user->table[$j]=$tableID;
                $j++;
              }
            }
          }
        }
      }
    }
  }
  $gotData->user->totalRows=count($gotData->user->tableBooking);
  return $gotData;
}
function getTableList($gotData){
  $userID=$gotData->user->userID;
  $personNum=$gotData->user->personNum;
  $sql="SELECT * FROM book_table";
  $result=mysqli_query($gotData->con,$sql);
  if($result){
    $gotData->user->totalRows=mysqli_num_rows($result);
    if($gotData->user->totalRows>0){
      $i=0;
      while($row=mysqli_fetch_array($result)){
        $gotData->user->table[$i]=(object) null;
        if($row['person']>=$personNum){
          $gotData->user->table[$i]->isAvail=true;
        }else{
          $gotData->user->table[$i]->isAvail=false;
        }
        $gotData->user->table[$i]->id=$row['id'];
        $gotData->user->table[$i]->name=$row['table'];
        $i++;
      }
    }
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Try again!";
  return $gotData;
}
function availablSlotList($con,$usedSlot){
  $j=0;
  $slotTime=[];
  $sql="SELECT * FROM time_slot";
  $result=mysqli_query($con,$sql);
  if($result){
    while($row=mysqli_fetch_array($result)){
      $slot=$row['slot'];
      $slotArr=explode("-",$slot);
      $start=$slotArr[0];
      $end=$slotArr[1];
      $diff=checkDiffHour($start);
      if($diff>0 && !in_array($slot,$slotTime)){
        $slotTime[$j]=(object) null;
        $slotTime[$j]->name=$slot;
        $slotTime[$j]->id=$row['id'];
        $slotTime[$j]->isAvail=true;
        $j++;
      }
    }
  }
  if(count($usedSlot)>=1){
    $k=0;
    for($i=0;$i<count($slotTime);$i++){
      $flag=0;
      for($j=0;$j<count($usedSlot);$j++){
        if($slotTime[$i]->name==$usedSlot[$j]){
          $slotTime[$i]->isAvail=false;
        }
      }
    }
  }
  return $slotTime;
}
function checkDiffHour($start){
  $date1 = mktime($start, 0, 0);
  $date2 = mktime(date("H"), date("i"), 0);
  $diff=$date1-$date2;
  return $diff;
}
function getSlotTimeList($gotData){
  $userID=$gotData->user->userID;
  $tableID=$gotData->user->tableID;
  $table[0]=$tableID;
  $gotData=availableTableList($gotData,$table,true);
  $i=0;
  if(count($gotData->user->tableBooking)==0){
    $gotData->user->slot=availablSlotList($gotData->con,[]);
    $gotData->user->totalRows=count($gotData->user->slot);
    return $gotData;
  }
  for($k=0;$k<count($gotData->user->tableBooking);$k++){
    $tableBookingID=$gotData->user->tableBooking[$k];
    $sql="SELECT table_booking.tid as tid, time_slot.slot as slot FROM table_booking INNER JOIN time_slot ON table_booking.slot_id=time_slot.id WHERE table_booking.id='$tableBookingID'";
    $result=mysqli_query($gotData->con,$sql);
    if($result){
      if(mysqli_num_rows($result)>0){
        while($row=mysqli_fetch_array($result)){
          $slot=$row['slot'];
          if(!in_array($slot,$usedSlot)){
            $usedSlot[$i]=(object) null;
            $usedSlot[$i]=$row['slot'];
            $i++;
          }
        }
      }
    }
  }
  $gotData->b->usedSlot=$usedSlot;
  if($i!=0){
    $gotData->user->usedSlot=$usedSlot;
    $gotData->user->slot=availablSlotList($gotData->con,$usedSlot);
  }
  $gotData->user->totalRows=count($gotData->user->slot);
  return $gotData;
}
// function checkTableAlreadyBooked($con,$userID,$tableID,$slotID){
//   $sql="SELECT * FROM table_booking WHERE uid='$userID'";
//   $result=mysqli_query($con,$sql);
//   if($result){
//     if(mysqli_num_rows($result)>0){
//       $row=mysqli_fetch_array($result);
//       $date=$row['date'];
//       // $date1=strtotime(date('Y-m-d H:i:s'));
//       // $date2=strtotime($date);
//       // $diff=floor(($date1-$date2)/(60*60*24));
//       $slot=$row['slotName'];
//       $slotArr=explode("-",$slot);
//       $start=$slotArr[0];
//       $end=$slotArr[1];
//       $diff=checkDiffHour($end);
//       if($diff>0){
//         return true;
//       }
//       else{
//         return false;
//       }
//     }else{
//       return false;
//     }
//   }
//   return false;
// }

function bookTable($gotData){
  $userID=$gotData->user->userID;
  $tableID=$gotData->user->tableID;
  $slotID=$gotData->user->slotID;
  // $got=(object) null;
  // $got->error=false;
  // $got->con=$gotData->con;
  // $got->user=(object) null;
  // $got->user->userID=$userID;
  // $got=getTableBookedData($got);
  // if($got->error) return $got;
  $sql="INSERT INTO table_booking(tid,uid,slot_id) VALUES('$tableID','$userID','$slotID')";
  $result=mysqli_query($gotData->con,$sql);
  if($result){
    $gotData=getTableBookedData($gotData,false);
    if($gotData->error) return $gotData;
    $gotData->responseMessage="Table Booked Successfully";
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Try again!";
  return $gotData;
}
function getTableBookedData($gotData,$state){
  $userID=$gotData->user->userID;
  $sql="SELECT table_booking.id as `id`, book_table.table as `tableName`,time_slot.slot as `slotName`, table_booking.date as `date`, table_booking.tid as `tableID`, table_booking.slot_id as `slotID`, table_booking.uid as `userID` FROM book_table INNER JOIN table_booking ON table_booking.tid=book_table.id INNER JOIN time_slot ON table_booking.slot_id=time_slot.id WHERE table_booking.uid='$userID'";
  $result=mysqli_query($gotData->con,$sql);
  if($result){
    while($row=mysqli_fetch_array($result)){
      $date=$row['date'];
      // $date1=strtotime(date('Y-m-d H:i:s'));
      // $date2=strtotime($date);
      // $diff=floor(($date1-$date2)/(60*60*24));
      $date1=strtotime(date('Y-m-d H:i:s'));
      $date2=strtotime($date);
      $diff_day=floor(($date1-$date2)/(60*60*24));
      if($diff_day==0){
          $slot=$row['slotName'];
          $slotArr=explode("-",$slot);
          $start=$slotArr[0];
          $end=$slotArr[1];
          if($state){
              $diff=checkDiffHour($end);
          }else{
              $diff=checkDiffHour($start);
          }
          if($diff>0){
            $gotData->user->isTableBooked=true;
            $gotData->user->tableBooking=(object) null;
            $gotData->user->tableBooking->id=$row['id'];
            $gotData->user->tableBooking->tableID=$row['tableID'];
            $gotData->user->tableBooking->userID=$row['userID'];
            $gotData->user->tableBooking->slotID=$row['slotID'];
            $gotData->user->tableBooking->tableName=$row['tableName'];
            $gotData->user->tableBooking->slotName=$row['slotName'];
            $gotData->user->tableBooking->date=date("d-m-Y H:i",strtotime($date));
            $gotData->user->tableBooking->day=date("D",strtotime($date));
            return $gotData;
          }
      }
    }
    $gotData->user->isTableBooked=false;
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Try again!1";
  return $gotData;
}
function removeBookedTable($gotData){
  $userID= $gotData->user->userID;
  $tableBookingID= $gotData->user->tableBookingID;
  $sql="DELETE FROM table_booking WHERE uid='$userID' AND id='$tableBookingID'";
  $result=mysqli_query($gotData->con,$sql);
  if($result){
    $gotData->responseMessage="Table Booking cancelled successfully.";
    return $gotData;
  }
  $gotData->error=true;
  $gotData->errorMessage="Try again!1";
  return $gotData;
}
$gotData=(object) null;
$gotData->user=(object)null;
$gotData->error=false;
$gotData->errorMessage=null;
if(isset($_REQUEST['action'])){
  $action = $_REQUEST['action'];
  if($action==1 && isset($_REQUEST['userID']) && isset($_REQUEST['personNum'])){
    $gotData->con=$con;
    $gotData->user->userID=$_REQUEST['userID'];
    $gotData->user->personNum=$_REQUEST['personNum'];
    $gotData=getTableList($gotData);
    $gotData->con=(object) null;
    echo json_encode($gotData);
    exit();
  }else if($action==2 && isset($_REQUEST['userID']) && isset($_REQUEST['tableID'])){
    $gotData->con=$con;
    $gotData->user->userID=$_REQUEST['userID'];
    $gotData->user->tableID=$_REQUEST['tableID'];
    $gotData=getSlotTimeList($gotData);
    $gotData->con=(object) null;
    echo json_encode($gotData);
    exit();
  }
  else if($action==3 && isset($_REQUEST['userID']) && isset($_REQUEST['tableID']) && isset($_REQUEST['slotID'])){
    $gotData->con=$con;
    $gotData->user->userID=$_REQUEST['userID'];
    $gotData->user->tableID=$_REQUEST['tableID'];
    $gotData->user->slotID=$_REQUEST['slotID'];
    $gotData=bookTable($gotData);
    $gotData->con=(object) null;
    echo json_encode($gotData);
    exit();
  }else if($action==4 && isset($_REQUEST['userID'])){
    $gotData->con=$con;
    $gotData->user->userID=$_REQUEST['userID'];
    $gotData=getTableBookedData($gotData,true);
    $gotData->con=(object) null;
    echo json_encode($gotData);
    exit();
  }else if($action==5 && isset($_REQUEST['userID']) && isset($_REQUEST['tableBookingID'])){
    $gotData->con=$con;
    $gotData->user->userID=$_REQUEST['userID'];
    $gotData->user->tableBookingID=$_REQUEST['tableBookingID'];
    $gotData=removeBookedTable($gotData);
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
