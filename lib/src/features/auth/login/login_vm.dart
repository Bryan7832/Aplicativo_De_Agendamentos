import 'package:asyncstate/asyncstate.dart';
import 'package:pi2/src/core/exceptions/service_exception.dart';
import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/providers/application_providers.dart';
import 'package:pi2/src/features/auth/login/login_state.dart';
import 'package:pi2/src/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer';

part 'login_vm.g.dart';

@riverpod
class LoginVM extends _$LoginVM {
  @override
  LoginState build() => const LoginState.initial();

  Future<void> login(String email, String password) async {
    final loaderHandler = AsyncLoaderHandler()..start();

    try {
      state = const LoginState.initial();

      final loginService = ref.watch(userLoginServiceProvider);
      final result = await loginService.execute(
        email: email,
        password: password,
      );

      switch (result) {
        case Success():
          // Invalidate providers in a safe way
          ref.invalidate(getMeProvider);
          ref.invalidate(getMyBarbeariapiProvider);

          // Delay slightly to ensure providers are properly reset
          await Future.delayed(const Duration(milliseconds: 200));

          try {
            // Safely fetch user data with timeout protection
            final userModel = await ref
                .read(getMeProvider.future)
                .timeout(const Duration(seconds: 5));

            switch (userModel) {
              case UserModelADM():
                state = state.copyWith(status: LoginStateStatus.admLogin);
                break;
              case UserModelEmployee():
                state = state.copyWith(status: LoginStateStatus.employeeLogin);
                break;
            }
          } catch (e, s) {
            log(
              'Erro ao buscar dados do usuário após login',
              error: e,
              stackTrace: s,
            );
            state = state.copyWith(
              status: LoginStateStatus.error,
              errorMessage:
                  () => 'Erro ao carregar dados do usuário. Tente novamente.',
            );
          }

        case Failure(exception: ServiceException(:final message)):
          state = state.copyWith(
            status: LoginStateStatus.error,
            errorMessage: () => message,
          );
      }
    } catch (e, s) {
      log('Erro não tratado no processo de login', error: e, stackTrace: s);
      state = state.copyWith(
        status: LoginStateStatus.error,
        errorMessage:
            () => 'Ocorreu um erro inesperado. Tente novamente mais tarde.',
      );
    } finally {
      loaderHandler.close();
    }
  }
}
