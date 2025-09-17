import 'package:asyncstate/asyncstate.dart';
import 'package:pi2/src/core/exceptions/repository_exception.dart';
import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/fp/nil.dart';
import 'package:pi2/src/core/providers/application_providers.dart';
import 'package:pi2/src/features/employee/register/employee_register_state.dart';
import 'package:pi2/src/models/barbeariapi_model.dart';
import 'package:pi2/src/repositories/user/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'employee_register_vm.g.dart';

@riverpod
class EmployeeRegisterVM extends _$EmployeeRegisterVM {
  @override
  EmployeeRegisterState build() => EmployeeRegisterState.initial();

  void setRegisterADM(bool isRegisterADM) {
    state = state.copyWith(registerADM: isRegisterADM);
  }

  void addOrRemoveWeekDays(String weekDay) {
    final EmployeeRegisterState(:workDays) = state;

    if (workDays.contains(weekDay)) {
      workDays.remove(weekDay);
    } else {
      workDays.add(weekDay);
    }

    state = state.copyWith(workDays: workDays);
  }

  void addOrRemoveWorkHours(int workHour) {
    final EmployeeRegisterState(:workHours) = state;

    if (workHours.contains(workHour)) {
      workHours.remove(workHour);
    } else {
      workHours.add(workHour);
    }

    state = state.copyWith(workHours: workHours);
  }

  Future<void> register({String? name, String? email, String? password}) async {
    final EmployeeRegisterState(:registerADM, :workDays, :workHours) = state;
    final asyncLoaderHandler = AsyncLoaderHandler()..start();

    final UserRepository(:registerADMAsEmployee, :registerEmployee) = ref.read(
      userRepositoryProvider,
    );

    final Either<RepositoryException, Nil> resultRegister;

    if (registerADM) {
      final dto = (workDays: workDays, workHours: workHours);
      resultRegister = await registerADMAsEmployee(dto);
    } else {
      final BarbeariapiModel(:id) = await ref.watch(
        getMyBarbeariapiProvider.future,
      );
      final dto = (
        barbeariapiId: id,
        name: name!,
        email: email!,
        password: password!,
        workDays: workDays,
        workHours: workHours,
      );

      resultRegister = await registerEmployee(dto);
    }

    state = state.copyWith(
      status: switch (resultRegister) {
        Success() => EmployeeRegisterStateStatus.success,
        Failure() => EmployeeRegisterStateStatus.error,
      },
    );

    asyncLoaderHandler.close();
  }
}
