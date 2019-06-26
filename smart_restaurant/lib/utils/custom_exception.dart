class FormCustomException implements Exception {
  String field;
  String message;
  FormCustomException(String message, String field) {
    this.message = message;
    this.field = field;
  }
  @override
  String toString() {
    return message;
  }
}

class CustomException implements Exception {
  String message;
  CustomException(String error) {
    this.message = error;
  }
  @override
  String toString() {
    return "$message";
  }
}

class FormException implements Exception {
  String message;
  FormException(String message) {
    this.message = message;
  }
  @override
  String toString() {
    return message;
  }
}
