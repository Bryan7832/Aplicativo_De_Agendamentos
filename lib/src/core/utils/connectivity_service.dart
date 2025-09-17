import 'dart:io';
import 'dart:async';
import 'dart:developer';

class ConnectivityService {
  /// Verifica se há conexão com a internet
  static Future<bool> hasInternetConnection({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    try {
      // Tenta se conectar ao Google DNS
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      log('Erro ao verificar conexão', error: e);
      return false;
    }
  }

  /// Verifica se o servidor da API está acessível
  static Future<bool> isApiServerReachable({
    required String host,
    required int port,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (e) {
      log('Servidor indisponível: $host:$port', error: e);
      return false;
    }
  }
}
