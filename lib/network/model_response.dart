abstract class Result<T> {}

class Success<T> extends Result {
  final T value;
  Success(this.value);
}

class Error<T> extends Result {
  final Exception exception;
  Error(this.exception);
}
