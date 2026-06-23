sealed class Resource<T> {
  const Resource();
}

class Loading<T> extends Resource<T> {
  const Loading();
}

class Success<T> extends Resource<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Resource<T> {
  final String message;
  const Error(this.message);
}
