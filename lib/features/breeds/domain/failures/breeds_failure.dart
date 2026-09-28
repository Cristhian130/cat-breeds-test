/// Fallos comprendidos por el feature de razas, sin detalles de la capa
/// de transporte.
sealed class BreedsFailure {
  const new();
}

/// No hay conexión o la solicitud agotó el tiempo de espera.
final class ConnectionFailure extends BreedsFailure {
  const new();
}

/// La API rechazó la solicitud o sus credenciales.
final class AccessDeniedFailure extends BreedsFailure {
  const new();
}

/// Se alcanzó la cuota o el límite de solicitudes de la API.
final class RateLimitFailure extends BreedsFailure {
  const new();
}

/// La raza solicitada no existe.
final class BreedNotFoundFailure extends BreedsFailure {
  const new();
}

/// La respuesta de la API no pudo interpretarse como una raza válida.
final class InvalidBreedDataFailure extends BreedsFailure {
  const new();
}

/// Un término de búsqueda supera el límite de 30 caracteres de la API.
final class InvalidSearchTermFailure extends BreedsFailure {
  const new();
}

/// Fallo no cubierto por los casos conocidos.
final class UnexpectedBreedsFailure extends BreedsFailure {
  const new();
}
