abstract class Failure {
  String get message;
}

class ServerFailure extends Failure {
  @override
  final String message;
  final int? statusCode;

  ServerFailure({required this.message, this.statusCode});
}

//400- bad Request
class BadRequestFailure extends Failure {
  @override
  final String message;
  final int? statusCode = 400;
  BadRequestFailure([this.message = 'Solicitud incorrecta']);
}

class UnauthorizedFailure extends Failure {
  @override
  final String message;
  final int statusCode = 401;

  UnauthorizedFailure([this.message = 'No autorizado']);
}

// 403 - Forbidden
class ForbiddenFailure extends Failure {
  @override
  final String message;
  final int statusCode = 403;

  ForbiddenFailure([this.message = 'Acceso prohibido']);
}

// 404 - Not Found
class NotFoundFailure extends Failure {
  @override
  final String message;
  final int statusCode = 404;

  NotFoundFailure([this.message = 'Recurso no encontrado']);
}

// 422 - Unprocessable Entity (validación)
class ValidationFailure extends Failure {
  @override
  final String message;
  final int statusCode = 422;
  final Map<String, List<String>>? errors;

  ValidationFailure({this.message = 'Error de validación', this.errors});
}

// 500 - Internal Server Error
class InternalServerFailure extends Failure {
  @override
  final String message;
  final int statusCode = 500;

  InternalServerFailure([this.message = 'Error interno del servidor']);
}

// Errores de red (sin conectividad)
class NetworkFailure extends Failure {
  @override
  final String message;
  final int? statusCode = null;

  NetworkFailure([this.message = 'Error de conexión de red']);
}

// Errores de caché
class CacheFailure extends Failure {
  @override
  final String message;
  final int? statusCode = null;

  CacheFailure([this.message = 'Error de caché']);
}
