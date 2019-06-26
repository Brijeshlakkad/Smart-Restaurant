<?php
class User{
  var $id,$email,$name,$password,$mobile,$city,$address,$error,$errorMessage;
  function getData($con,$sql){
    $check=mysqli_query($con,$sql);
    if($check && (mysqli_num_rows($check)==1))
    {
      $row=mysqli_fetch_array($check);
      $this->id=$row['id'];
      $this->name=$row['name'];
      $this->email=$row['email'];
      $this->password=$row['password'];
      $this->address=$row['address'];
      $this->city=$row['city'];
      $this->mobile=$row['mobile'];
      $this->error=false;
      $this->errorMessage="null";
    }
    else{
      $this->error=true;
      $this->errorMessage="You do not have account in our app. Please register yourself at OUR app";
    }
  }
}
function getUserDataUsingEmail($con,$email){
  $u = new User;
  $sql="SELECT * FROM customer where email='$email'";
  $u->getData($con,$sql);
  return $u;
}
function getUserDataUsingID($con,$id){
  $u = new User;
  $sql="SELECT * FROM customer where id='$id'";
  $u->getData($con,$sql);
  return $u;
}
?>
