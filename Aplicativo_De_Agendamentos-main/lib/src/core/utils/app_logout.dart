import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi2/src/core/constants/local_storage_keys.dart';
import 'package:pi2/src/core/ui/barbeariapi_nav_global_key.dart';
import 'dart:developer';

class AppLogout {
  static Future<void> cleanAndNavigateToLogin({
    String message = 'Sua sessão expirou. Por favor, faça login novamente.',
  }) async {
    try {
      // Limpa todos os dados de autenticação
      final sp = await SharedPreferences.getInstance();
      await sp.remove(LocalStorageKeys.accessToken);

      // Obtém o contexto de navegação
      final navContext = BarbeariapiNavGlobalKey.instance.navKey.currentContext;
      if (navContext != null) {
        // Exibe uma mensagem para o usuário (opcional)
        ScaffoldMessenger.of(navContext).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navega para a tela de login
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.of(
          navContext,
        ).pushNamedAndRemoveUntil('/auth/login', (route) => false);
      }
    } catch (e, s) {
      log('Erro ao realizar logout', error: e, stackTrace: s);
    }
  }

  // Método para limpar tokens no início do app se necessário
  static Future<void> clearInvalidTokensOnStartup() async {
    try {
      // Limpa todos os dados de autenticação para começar limpo
      final sp = await SharedPreferences.getInstance();

      // Verifica se o token está presente mas potencialmente inválido
      final token = sp.getString(LocalStorageKeys.accessToken);

      if (token != null) {
        // Aqui você poderia adicionar uma lógica para verificar se o token é válido
        // Por enquanto, vamos apenas garantir que não tenha ficado em um estado inválido
        log('Limpando token antigo durante inicialização');
        await sp.remove(LocalStorageKeys.accessToken);
      }
    } catch (e, s) {
      log('Erro ao limpar tokens na inicialização', error: e, stackTrace: s);
    }
  }
}
