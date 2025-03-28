import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../failures.dart';

/// Servicio para realizar reintentos de operaciones con políticas configurables.
abstract class RetryService {
  /// Reintenta una operación con política de retroceso exponencial.
  ///
  /// [operation]: La operación a reintentar.
  /// [maxAttempts]: Número máximo de intentos.
  /// [initialDelay]: Retraso inicial entre intentos en milisegundos.
  /// [factor]: Factor por el que aumenta el retraso en cada intento.
  /// [shouldRetry]: Función que determina si se debe reintentar basado en el error.
  Future<Either<Failure, T>> retryWithBackoff<T>(
    Future<Either<Failure, T>> Function() operation, {
    int maxAttempts = 3,
    int initialDelay = 500,
    double factor = 2.0,
    bool Function(Failure)? shouldRetry,
  });

  /// Reintenta una operación con un intervalo fijo.
  ///
  /// [operation]: La operación a reintentar.
  /// [maxAttempts]: Número máximo de intentos.
  /// [delay]: Retraso constante entre intentos en milisegundos.
  /// [shouldRetry]: Función que determina si se debe reintentar basado en el error.
  Future<Either<Failure, T>> retryWithFixedDelay<T>(
    Future<Either<Failure, T>> Function() operation, {
    int maxAttempts = 3,
    int delay = 1000,
    bool Function(Failure)? shouldRetry,
  });
}

@LazySingleton(as: RetryService)
class RetryServiceImpl implements RetryService {
  @override
  Future<Either<Failure, T>> retryWithBackoff<T>(
    Future<Either<Failure, T>> Function() operation, {
    int maxAttempts = 3,
    int initialDelay = 500,
    double factor = 2.0,
    bool Function(Failure)? shouldRetry,
  }) async {
    int attempts = 0;
    int currentDelay = initialDelay;

    while (true) {
      attempts++;

      try {
        final result = await operation();

        if (result.isRight()) {
          return result;
        }

        // Si hay un error, verificar si debemos reintentar
        final failure = result.fold((l) => l, (r) => null);
        if (failure == null) {
          return result; // No debería ocurrir, pero por seguridad
        }

        final canRetry =
            shouldRetry?.call(failure) ?? _defaultShouldRetry(failure);

        if (!canRetry || attempts >= maxAttempts) {
          return result; // No reintentar o alcanzado el máximo de intentos
        }

        // Esperar con retroceso exponencial
        await Future.delayed(Duration(milliseconds: currentDelay));
        currentDelay = (currentDelay * factor).round();
      } catch (e) {
        // Error inesperado
        if (attempts >= maxAttempts) {
          return Left(ServerFailure(message: e.toString()));
        }

        // Esperar con retroceso exponencial
        await Future.delayed(Duration(milliseconds: currentDelay));
        currentDelay = (currentDelay * factor).round();
      }
    }
  }

  @override
  Future<Either<Failure, T>> retryWithFixedDelay<T>(
    Future<Either<Failure, T>> Function() operation, {
    int maxAttempts = 3,
    int delay = 1000,
    bool Function(Failure)? shouldRetry,
  }) async {
    int attempts = 0;

    while (true) {
      attempts++;

      try {
        final result = await operation();

        if (result.isRight()) {
          return result;
        }

        // Si hay un error, verificar si debemos reintentar
        final failure = result.fold((l) => l, (r) => null);
        if (failure == null) {
          return result; // No debería ocurrir, pero por seguridad
        }

        final canRetry =
            shouldRetry?.call(failure) ?? _defaultShouldRetry(failure);

        if (!canRetry || attempts >= maxAttempts) {
          return result; // No reintentar o alcanzado el máximo de intentos
        }

        // Esperar con retraso fijo
        await Future.delayed(Duration(milliseconds: delay));
      } catch (e) {
        // Error inesperado
        if (attempts >= maxAttempts) {
          return Left(ServerFailure(message: e.toString()));
        }

        // Esperar con retraso fijo
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
  }

  /// Determina si se debe reintentar basado en el tipo de error.
  bool _defaultShouldRetry(Failure failure) {
    // Por defecto, reintentar errores de red y servidor, pero no errores de validación o autenticación
    return failure is NetworkFailure ||
        failure is ServerFailure ||
        failure is InternalServerFailure;
  }
}
