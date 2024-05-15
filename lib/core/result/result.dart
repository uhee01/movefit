// ignore_for_file: public_member_api_docs, sort_constructors_first

class Result<T> {
  final T? _data;
  final String? _errorMessage;

  Result({
    required T? data,
    String? errorMessage,
  })  : _data = data,
        _errorMessage = errorMessage;

  T? get data => _data;
  String? get errorMessage => _errorMessage;

  factory Result.success(T data) {
    return Result(data: data, errorMessage: null);
  }
  factory Result.failure(String errorMessage) {
    return Result(data: null, errorMessage: errorMessage);
  }
}
