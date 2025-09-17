import 'dart:developer';

import 'package:pi2/src/core/exceptions/repository_exception.dart';
import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/fp/nil.dart';
import 'package:pi2/src/core/rest_client/rest_client.dart';
import 'package:pi2/src/models/schedule_model.dart';
import 'package:pi2/src/repositories/schedule/schedule_repository.dart';
import 'package:dio/dio.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl({required RestClient restClient})
    : _restClient = restClient;

  final RestClient _restClient;

  @override
  Future<Either<RepositoryException, Nil>> scheduleClient(
    ({
      int barbeariapiId,
      String clientName,
      DateTime date,
      int time,
      int userId,
    })
    scheduleData,
  ) async {
    try {
      await _restClient.auth.post(
        '/schedules',
        data: {
          'barbeariapi_id': scheduleData.barbeariapiId,
          'user_id': scheduleData.userId,
          'client_name': scheduleData.clientName,
          'date': scheduleData.date.toIso8601String(),
          'time': scheduleData.time,
        },
      );
      return Success(nil);
    } on DioException catch (e, s) {
      const errorMessage = 'Erro ao registrar agendamento';
      log(errorMessage, error: e, stackTrace: s);
      return Failure(const RepositoryException(message: errorMessage));
    }
  }

  @override
  Future<Either<RepositoryException, List<ScheduleModel>>> findScheduleByDate(
    ({DateTime date, int userId}) filter,
  ) async {
    try {
      final Response(:List data) = await _restClient.auth.get(
        '/schedules',
        queryParameters: {
          'user_id': filter.userId,
          'date': filter.date.toIso8601String(),
        },
      );
      return Success(data.map((s) => ScheduleModel.fromMap(s)).toList());
    } on DioException catch (e, s) {
      const errorMessage = 'Erro ao buscar agendamento de uma data';
      log(errorMessage, error: e, stackTrace: s);
      return Failure(const RepositoryException(message: errorMessage));
    } on ArgumentError catch (e, s) {
      const errorMessage = 'Json inválido';
      log(errorMessage, error: e, stackTrace: s);
      return Failure(const RepositoryException(message: errorMessage));
    }
  }
}
