import 'package:pi2/src/core/exceptions/repository_exception.dart';
import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/fp/nil.dart';
import 'package:pi2/src/models/barbeariapi_model.dart';
import 'package:pi2/src/models/user_model.dart';

abstract interface class BarbeariapiRepository {
  Future<Either<RepositoryException, BarbeariapiModel>> getMyBarbeariapi(
    UserModel userModel,
  );

  Future<Either<RepositoryException, Nil>> save(
    ({
      String name,
      String email,
      List<String> openingDays,
      List<int> openingHours,
    })
    data,
  );

  // Método para atualizar o nome da barbearia
  Future<Either<RepositoryException, Nil>> updateBarbeariapi({
    required int barbeariapiId,
    required String name,
    String? email,
  });
}
