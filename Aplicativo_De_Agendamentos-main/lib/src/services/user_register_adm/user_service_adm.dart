import 'package:pi2/src/core/exceptions/service_exception.dart';
import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/fp/nil.dart';

abstract interface class UserRegisterServiceADM {
  Future<Either<ServiceException, Nil>> execute(
    ({String name, String email, String password}) userData,
  );
}
