// ignore_for_file: public_member_api_docs, sort_constructors_first
class ListOperationException implements Exception {
  String errorMessage;
  ListOperationException({
    required this.errorMessage,
  });
}
