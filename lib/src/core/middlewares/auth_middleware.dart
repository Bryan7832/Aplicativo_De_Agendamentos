import 'package:pi2/src/core/constants/local_storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class AuthMiddleware {
  static Future<bool> verifyToken() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final accessToken = sp.getString(LocalStorageKeys.accessToken);

      if (accessToken == null) {
        return false;
      }

      // Aqui você pode adicionar verificação adicional do token
      // como verificar se está expirado, etc.

      return true;
    } catch (e, s) {
      log('Erro ao verificar token', error: e, stackTrace: s);
      return false;
    }
  }

  static Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(LocalStorageKeys.accessToken);
  }
}
