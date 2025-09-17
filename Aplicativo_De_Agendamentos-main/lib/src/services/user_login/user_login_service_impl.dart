import 'dart:developer';
import 'package:pi2/src/core/constants/local_storage_keys.dart';
import 'package:pi2/src/core/exceptions/auth_exception.dart';
import 'package:pi2/src/core/exceptions/service_exception.dart';
import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/fp/nil.dart';
import 'package:pi2/src/repositories/user/user_repository.dart';
import 'package:pi2/src/services/user_login/user_login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class UserLoginServiceImpl implements UserLoginService {
  UserLoginServiceImpl({required UserRepository userRepository})
    : _userRepository = userRepository;

  final UserRepository _userRepository;

  @override
  Future<Either<ServiceException, Nil>> execute({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _userRepository.login(
        email: email,
        password: password,
      );

      switch (result) {
        case Success(:final value):
          try {
            final sharedPreferences = await SharedPreferences.getInstance();
            await sharedPreferences.setString(
              LocalStorageKeys.accessToken,
              value,
            );
            return Success(nil);
          } catch (e, s) {
            log('Erro ao salvar o token de acesso', error: e, stackTrace: s);
            return Failure(
              const ServiceException(
                message: 'Erro ao salvar credenciais de login',
              ),
            );
          }
        case Failure(:final exception):
          return switch (exception) {
            AuthError() => Failure(
              ServiceException(message: exception.message),
            ),
            AuthUnauthorizedException() => Failure(
              const ServiceException(message: 'Login ou senha inválidos'),
            ),
          };
      }
    } catch (e, s) {
      log('Erro não esperado no serviço de login', error: e, stackTrace: s);
      return Failure(
        ServiceException(
          message: 'Erro interno no serviço de autenticação: ${e.toString()}',
        ),
      );
    }
  }
}
