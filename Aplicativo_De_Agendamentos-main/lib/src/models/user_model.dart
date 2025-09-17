import 'dart:developer';

sealed class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profile,
    this.avatar,
  });

  final int id;
  final String name;
  final String email;
  final String profile;
  final String? avatar;

  factory UserModel.fromMap(Map<String, dynamic> json) {
    try {
      return switch (json['profile']) {
        'ADM' => UserModelADM.fromMap(json),
        'EMPLOYEE' => UserModelEmployee.fromMap(json),
        _ => throw ArgumentError('Invalid user profile'),
      };
    } catch (e, s) {
      log('Error parsing UserModel: $e', error: e, stackTrace: s);
      throw ArgumentError('Invalid JSON format: ${json.toString()}');
    }
  }
}

class UserModelADM extends UserModel {
  UserModelADM({
    required super.id,
    required super.name,
    required super.email,
    required this.workDays,
    required this.workHours,
    super.avatar,
  }) : super(profile: 'ADM');

  final List<String>? workDays;
  final List<int>? workHours;

  factory UserModelADM.fromMap(Map<String, dynamic> json) {
    try {
      List<String>? workDays;
      if (json['work_days'] != null) {
        workDays = List<String>.from(json['work_days']);
      }

      List<int>? workHours;
      if (json['work_hours'] != null) {
        workHours = List<int>.from(json['work_hours']);
      }

      return UserModelADM(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        workDays: workDays,
        workHours: workHours,
        avatar: json['avatar'],
      );
    } catch (e, s) {
      log('Error parsing UserModelADM: $e', error: e, stackTrace: s);
      throw ArgumentError('Invalid ADM user data: ${json.toString()}');
    }
  }
}

class UserModelEmployee extends UserModel {
  UserModelEmployee({
    required super.id,
    required super.name,
    required super.email,
    required this.barbeariapiId,
    required this.workDays,
    required this.workHours,
    super.avatar,
  }) : super(profile: 'EMPLOYEE');

  final int barbeariapiId;
  final List<String> workDays;
  final List<int> workHours;

  factory UserModelEmployee.fromMap(Map<String, dynamic> json) {
    try {
      return UserModelEmployee(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        barbeariapiId: json['barbeariapi_id'],
        workDays: List<String>.from(json['work_days']),
        workHours: List<int>.from(json['work_hours']),
        avatar: json['avatar'],
      );
    } catch (e, s) {
      log('Error parsing UserModelEmployee: $e', error: e, stackTrace: s);
      throw ArgumentError('Invalid employee user data: ${json.toString()}');
    }
  }
}
