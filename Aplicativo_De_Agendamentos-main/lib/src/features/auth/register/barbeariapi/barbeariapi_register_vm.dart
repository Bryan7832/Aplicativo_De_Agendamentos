import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/providers/application_providers.dart';
import 'package:pi2/src/features/auth/register/barbeariapi/barbeariapi_register_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'barbeariapi_register_vm.g.dart';

@riverpod
class BarbeariapiRegisterVM extends _$BarbeariapiRegisterVM {
  @override
  BarbeariapiRegisterState build() => BarbeariapiRegisterState.initial();

  void addOrRemoveOpeningDays(String weekDay) {
    final openingDays = state.openingDays;
    if (openingDays.contains(weekDay)) {
      openingDays.remove(weekDay);
    } else {
      openingDays.add(weekDay);
    }
    state = state.copyWith(openingDays: openingDays);
  }

  void addOrRemoveOpeningHours(int hour) {
    final openingHours = state.openingHours;
    if (openingHours.contains(hour)) {
      openingHours.remove(hour);
    } else {
      openingHours.add(hour);
    }
    state = state.copyWith(openingHours: openingHours);
  }

  Future<void> register({required String name, required String email}) async {
    final repository = ref.watch(barbeariapiRepositoryProvider);
    final BarbeariapiRegisterState(:openingDays, :openingHours) = state;

    final dto = (
      name: name,
      email: email,
      openingDays: openingDays,
      openingHours: openingHours,
    );

    final registerResult = await repository.save(dto);

    switch (registerResult) {
      case Success():
        ref.invalidate(getMyBarbeariapiProvider);
        state = state.copyWith(status: BarbeariapiRegisterStateStatus.success);
      case Failure():
        state = state.copyWith(status: BarbeariapiRegisterStateStatus.error);
    }
  }
}
