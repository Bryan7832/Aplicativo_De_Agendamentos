enum BarbeariapiRegisterStateStatus { initial, success, error }

final class BarbeariapiRegisterState {
  const BarbeariapiRegisterState({
    required this.status,
    required this.openingDays,
    required this.openingHours,
  });

  BarbeariapiRegisterState.initial()
    : status = BarbeariapiRegisterStateStatus.initial,
      openingDays = [],
      openingHours = [];

  final BarbeariapiRegisterStateStatus status;
  final List<String> openingDays;
  final List<int> openingHours;

  BarbeariapiRegisterState copyWith({
    BarbeariapiRegisterStateStatus? status,
    List<String>? openingDays,
    List<int>? openingHours,
  }) => BarbeariapiRegisterState(
    status: status ?? this.status,
    openingDays: openingDays ?? this.openingDays,
    openingHours: openingHours ?? this.openingHours,
  );
}
