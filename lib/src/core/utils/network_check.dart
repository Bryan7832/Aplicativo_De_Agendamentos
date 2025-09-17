import 'dart:io';
import 'dart:async';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';

class NetworkCheck {
  static Future<Map<String, dynamic>> diagnoseConnection({
    required String apiUrl,
    int port = 8080,
  }) async {
    final result = <String, dynamic>{
      'internetAvailable': false,
      'serverReachable': false,
      'pingTime': -1,
      'dnsLookup': false,
      'errors': <String>[],
    };

    try {
      // Teste básico de conectividade
      result['internetAvailable'] = await _checkInternetConnection();

      // Extrai o hostname da URL
      final uri = Uri.parse(apiUrl);
      final host = uri.host;

      // Testa DNS lookup
      try {
        final addresses = await InternetAddress.lookup(host);
        result['dnsLookup'] = addresses.isNotEmpty;
        if (addresses.isNotEmpty) {
          dev.log('DNS Lookup resolvido para: ${addresses.first.address}');
        }
      } catch (e) {
        result['errors'].add('Erro DNS: $e');
      }

      // Teste de conectividade TCP
      try {
        final stopwatch = Stopwatch()..start();
        final socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(seconds: 5),
        );
        result['pingTime'] = stopwatch.elapsedMilliseconds;
        socket.destroy();
        result['serverReachable'] = true;
      } catch (e) {
        result['errors'].add('Erro TCP: $e');
      }

      // Teste HTTP
      try {
        final dio = Dio();
        final stopwatch = Stopwatch()..start();
        final response = await dio.get(
          apiUrl,
          options: Options(
            validateStatus: (_) => true,
            receiveTimeout: const Duration(seconds: 5),
            sendTimeout: const Duration(seconds: 5),
          ),
        );
        final pingTime = stopwatch.elapsedMilliseconds;

        result['httpStatus'] = response.statusCode;
        result['httpPingTime'] = pingTime;
        dev.log('HTTP Status: ${response.statusCode}, Tempo: ${pingTime}ms');
      } catch (e) {
        result['errors'].add('Erro HTTP: $e');
      }
    } catch (e, s) {
      dev.log('Erro no diagnóstico de rede', error: e, stackTrace: s);
      result['errors'].add(e.toString());
    }

    dev.log('Diagnóstico de rede: $result');
    return result;
  }

  static Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
