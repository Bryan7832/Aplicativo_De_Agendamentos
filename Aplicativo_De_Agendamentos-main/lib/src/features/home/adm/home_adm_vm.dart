import 'package:asyncstate/asyncstate.dart';
import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/providers/application_providers.dart';
import 'package:pi2/src/features/home/adm/home_adm_state.dart';
import 'package:pi2/src/models/barbeariapi_model.dart';
import 'package:pi2/src/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_adm_vm.g.dart';

@riverpod
class HomeADMVM extends _$HomeADMVM {
  @override
  Future<HomeADMState> build() async {
    final repository = ref.read(userRepositoryProvider);
    final BarbeariapiModel(id: barbeariapiId) = await ref.read(
      getMyBarbeariapiProvider.future,
    );
    final me = await ref.watch(getMeProvider.future);

    final employeesResult = await repository.getEmployees(barbeariapiId);

    switch (employeesResult) {
      case Success(value: final employeesData):
        final employees = <UserModel>[];
        if (me case UserModelADM(workDays: _?, workHours: _?)) {
          employees.add(me);
        }
        employees.addAll(employeesData);
        return HomeADMState(
          status: HomeADMStateStatus.loaded,
          employees: employees,
        );
      case Failure():
        return HomeADMState(status: HomeADMStateStatus.error, employees: []);
    }
  }

  Future<void> logout() async => ref.watch(logoutProvider.future).asyncLoader();
}
