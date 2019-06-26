class CustomService {
  String ucFirst(String input) {
    List<String> inputList = input.split(new RegExp(" "));
    String output = "";
    for (int i = 0; i < inputList.length; i++) {
      if(i==0){
        output += inputList[i][0].toUpperCase() + inputList[i].substring(1);
      }else{
        output += " "+inputList[i][0].toUpperCase() + inputList[i].substring(1);
      }
    }
    return output;
  }
  String toString(){
    return "Custome Service\n Author: Brijesh Lakkad";
  }
}
