import 'dart:developer';

import 'package:pi2/src/core/exceptions/repository_exception.dart';
import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/fp/nil.dart';
import 'package:pi2/src/core/rest_client/rest_client.dart';
import 'package:pi2/src/models/barbeariapi_model.dart';
import 'package:pi2/src/models/user_model.dart';
import 'package:pi2/src/repositories/barbeariapi/barbeariapi_repository.dart';
import 'package:dio/dio.dart';

class BarbeariapiRepositoryImpl implements BarbeariapiRepository {
  BarbeariapiRepositoryImpl({required RestClient restClient})
    : _restClient = restClient;

  final RestClient _restClient;

  @override
  Future<Either<RepositoryException, BarbeariapiModel>> getMyBarbeariapi(
    UserModel userModel,
  ) async {
    switch (userModel) {
      case UserModelADM():
        final Response(data: List(first: data)) = await _restClient.auth.get(
          '/barbeariapi',
          queryParameters: {'user_id': '#userAuthRef'},
        );
        return Success(BarbeariapiModel.fromMap(data));
      case UserModelEmployee():
        final Response(:data) = await _restClient.auth.get(
          '/barbeariapi/${userModel.barbeariapiId}',
        );
        return Success(BarbeariapiModel.fromMap(data));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> save(
    ({
      String email,
      String name,
      List<String> openingDays,
      List<int> openingHours,
    })
    data,
  ) async {
    try {
      await _restClient.auth.post(
        '/barbeariapi',
        data: {
          'user_id': '#userAuthRef',
          'name': data.name,
          'email': data.email,
          'opening_days': data.openingDays,
          'opening_hours': data.openingHours,
        },
      );
      return Success(nil);
    } on DioException catch (e, s) {
      const errorMessage = 'Erro ao salvar barbearia';
      log(errorMessage, error: e, stackTrace: s);
      return Failure(const RepositoryException(message: errorMessage));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> updateBarbeariapi({
    required int barbeariapiId,
    required String name,
    String? email,
  }) async {
    try {
      final Map<String, dynamic> data = {'name': name};

      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }

      await _restClient.auth.put('/barbeariapi/$barbeariapiId', data: data);

      return Success(nil);
    } on DioException catch (e, s) {
      log('Erro ao atualizar dados da barbearia', error: e, stackTrace: s);
      return Failure(
        const RepositoryException(
          message: 'Erro ao atualizar dados da barbearia',
        ),
      );
    }
  }
}
