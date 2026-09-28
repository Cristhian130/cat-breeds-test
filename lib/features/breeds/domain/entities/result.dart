/// Valor exitoso o fallo tipado, sin dependencia de paquetes externos.
sealed class Result<T, E> {
  const new();
}

final class Success<T, E> extends Result<T, E> {
  const new(this.value);

  final T value;
}

final class Failure<T, E> extends Result<T, E> {
  const new(this.error);

  final E error;
}
