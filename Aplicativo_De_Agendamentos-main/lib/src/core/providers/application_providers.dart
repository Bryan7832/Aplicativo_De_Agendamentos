import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/rest_client/rest_client.dart';
import 'package:pi2/src/core/ui/barbeariapi_nav_global_key.dart';
import 'package:pi2/src/models/barbeariapi_model.dart';
import 'package:pi2/src/models/user_model.dart';
import 'package:pi2/src/repositories/barbeariapi/barbeariapi_repository.dart';
import 'package:pi2/src/repositories/barbeariapi/barbeariapi_repository_impl.dart';
import 'package:pi2/src/repositories/schedule/schedule_repository.dart';
import 'package:pi2/src/repositories/schedule/schedule_repository_impl.dart';
import 'package:pi2/src/repositories/user/user_repository.dart';
import 'package:pi2/src/repositories/user/user_repository_impl.dart';
import 'package:pi2/src/services/user_login/user_login_service.dart';
import 'package:pi2/src/services/user_login/user_login_service_impl.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'application_providers.g.dart';

@Riverpod(keepAlive: true)
RestClient restClient(RestClientRef ref) => RestClient();

@Riverpod(keepAlive: true)
UserRepository userRepository(UserRepositoryRef ref) =>
    UserRepositoryImpl(restClient: ref.read(restClientProvider));

@Riverpod(keepAlive: true)
UserLoginService userLoginService(UserLoginServiceRef ref) =>
    UserLoginServiceImpl(userRepository: ref.read(userRepositoryProvider));

@Riverpod(keepAlive: true)
Future<UserModel> getMe(GetMeRef ref) async {
  final result = await ref.watch(userRepositoryProvider).me();
  return switch (result) {
    Success(value: final userModel) => userModel,
    Failure(:final exception) => throw exception,
  };
}

@Riverpod(keepAlive: true)
BarbeariapiRepository barbeariapiRepository(BarbeariapiRepositoryRef ref) =>
    BarbeariapiRepositoryImpl(restClient: ref.watch(restClientProvider));

@Riverpod(keepAlive: true)
Future<BarbeariapiModel> getMyBarbeariapi(GetMyBarbeariapiRef ref) async {
  final userModel = await ref.watch(getMeProvider.future);
  final barbeariapiRepository = ref.watch(barbeariapiRepositoryProvider);
  final result = await barbeariapiRepository.getMyBarbeariapi(userModel);

  return switch (result) {
    Success(value: final barbeariapi) => barbeariapi,
    Failure(:final exception) => throw exception,
  };
}

@riverpod
Future<void> logout(LogoutRef ref) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.clear();
  ref.invalidate(getMeProvider);
  ref.invalidate(getMyBarbeariapiProvider);
  Navigator.of(
    BarbeariapiNavGlobalKey.instance.navKey.currentContext!,
  ).pushNamedAndRemoveUntil('/auth/login', (route) => false);
}

@riverpod
ScheduleRepository scheduleRepository(ScheduleRepositoryRef ref) =>
    ScheduleRepositoryImpl(restClient: ref.read(restClientProvider));
