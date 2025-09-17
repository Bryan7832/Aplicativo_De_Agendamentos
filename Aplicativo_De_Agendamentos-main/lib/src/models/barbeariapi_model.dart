final class BarbeariapiModel {
  const BarbeariapiModel({
    required this.id,
    required this.name,
    required this.email,
    required this.openDays,
    required this.openHours,
  });

  factory BarbeariapiModel.fromMap(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'name': String name,
        'email': String email,
        'opening_days': final List openDays,
        'opening_hours': final List openHours,
      } =>
        BarbeariapiModel(
          id: id,
          name: name,
          email: email,
          openDays: openDays.cast<String>(),
          openHours: openHours.cast<int>(),
        ),
      _ => throw ArgumentError('Invalid BarbeariapiModel JSON: $json'),
    };
  }

  final int id;
  final String name;
  final String email;
  final List<String> openDays;
  final List<int> openHours;
}
