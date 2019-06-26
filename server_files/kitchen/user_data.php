<?php
class User{
  var $id,$email,$name,$password,$mobile,$type,$error,$errorMessage;
  function getData($con,$sql){
    $check=mysqli_query($con,$sql);
    if($check && (mysqli_num_rows($check)==1))
    {
      $row=mysqli_fetch_array($check);
      $this->id=$row['id'];
      $this->name=$row['name'];
      $this->email=$row['email'];
      $this->password=$row['pass'];
      $this->type=$row['type'];
      $this->mobile=$row['mobile'];
      $this->error=false;
      $this->errorMessage="null";
    }
    else{
      $this->error=true;
      $this->errorMessage="Specific user doesn't exists.";
    }
  }
}
function getUserDataUsingEmail($con,$email){
  $u = new User;
  $sql="SELECT * FROM user where email='$email'";
  $u->getData($con,$sql);
  return $u;
}
function getUserDataUsingID($con,$id){
  $u = new User;
  $sql="SELECT * FROM user where id='$id'";
  $u->getData($con,$sql);
  return $u;
}
?>
