import 'package:pi2/src/core/exceptions/auth_exception.dart';
import 'package:pi2/src/core/exceptions/repository_exception.dart';
import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/fp/nil.dart';
import 'package:pi2/src/models/user_model.dart';
import 'dart:io';

abstract interface class UserRepository {
  Future<Either<AuthException, String>> login({
    required String email,
    required String password,
  });

  Future<Either<RepositoryException, UserModel>> me();

  Future<Either<RepositoryException, Nil>> registerAdmin(
    ({String name, String email, String password}) userData,
  );

  Future<Either<RepositoryException, List<UserModel>>> getEmployees(
    int barbeariapiId,
  );

  Future<Either<RepositoryException, Nil>> registerADMAsEmployee(
    ({List<String> workDays, List<int> workHours}) userModel,
  );

  Future<Either<RepositoryException, Nil>> registerEmployee(
    ({
      int barbeariapiId,
      String name,
      String email,
      String password,
      List<String> workDays,
      List<int> workHours,
    })
    userModel,
  );

  Future<Either<RepositoryException, Nil>> updateUserData({
    required int userId,
    required String name,
    required String email,
    String? password,
    File? avatarFile, // Adicionar este parâmetro
  });
}
