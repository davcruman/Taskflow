import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, 
      errorMethodCount: 5, 
      lineLength: 50, 
      colors: true, 
      printEmojis: true,
    ),
  );

  // Info: Para éxitos o mensajes informativos
  static void i(String message) => _logger.i(message);

  // Error: Para fallos críticos. Añadimos StackTrace opcional.
  // Esto te dirá exactamente en qué línea de qué archivo falló.
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // Warning: Para cosas que no son errores pero son raras
  static void w(String message) => _logger.w(message);
}