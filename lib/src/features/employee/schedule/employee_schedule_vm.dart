import 'package:pi2/src/core/exceptions/repository_exception.dart';
import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/providers/application_providers.dart';
import 'package:pi2/src/models/schedule_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'employee_schedule_vm.g.dart';

@riverpod
class EmployeeScheduleVM extends _$EmployeeScheduleVM {
  @override
  Future<List<ScheduleModel>> build(int userId, DateTime date) async =>
      switch (await _getSchedules(userId, date)) {
        Success(value: final schedules) => schedules,
        Failure(:final exception) => throw Exception(exception),
      };

  Future<void> changeDate(int userId, DateTime date) async =>
      state = switch (await _getSchedules(userId, date)) {
        Success(value: final schedules) => AsyncData(schedules),
        Failure(:final exception) =>
          AsyncError(Exception(exception), StackTrace.current),
      };

  Future<Either<RepositoryException, List<ScheduleModel>>> _getSchedules(
    int userId,
    DateTime date,
  ) =>
      ref
          .read(scheduleRepositoryProvider)
          .findScheduleByDate((userId: userId, date: date));
}
