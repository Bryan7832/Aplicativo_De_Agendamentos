import 'dart:developer';
import 'dart:io';

import 'package:pi2/src/core/exceptions/auth_exception.dart';
import 'package:pi2/src/core/exceptions/repository_exception.dart';
import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/fp/nil.dart';
import 'package:pi2/src/core/rest_client/rest_client.dart';
import 'package:pi2/src/models/user_model.dart';
import 'package:pi2/src/repositories/user/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl({required RestClient restClient})
    : _restClient = restClient;

  final RestClient _restClient;

  @override
  Future<Either<AuthException, String>> login({
    required String email,
    required String password,
  }) async {
    try {
      final Response(:data) = await _restClient.unAuth.post(
        '/auth',
        data: {'email': email, 'password': password},
      );

      log('Resposta da API de autenticação: $data');

      // Verifica se a resposta contém o campo access_token
      if (data is Map && data.containsKey('access_token')) {
        final accessToken = data['access_token'];
        if (accessToken is String) {
          return Success(accessToken);
        } else {
          log('Formato de token inválido: $accessToken');
          return Failure(
            const AuthError(
              message: 'Formato de resposta inválido do servidor',
            ),
          );
        }
      } else {
        log('Resposta não contém access_token: $data');
        return Failure(
          const AuthError(message: 'Resposta de autenticação inválida'),
        );
      }
    } on DioException catch (e, s) {
      if (e.response != null) {
        final Response(:statusCode) = e.response!;
        if (statusCode == HttpStatus.forbidden) {
          log('Login ou senha inválido login', error: e, stackTrace: s);
          return Failure(const AuthUnauthorizedException());
        }
      }
      log('Erro ao realizar login', error: e, stackTrace: s);
      return Failure(const AuthError(message: 'Erro ao realizar login'));
    } catch (e, s) {
      log('Erro inesperado durante o login', error: e, stackTrace: s);
      return Failure(AuthError(message: 'Erro não esperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, UserModel>> me() async {
    try {
      final Response(:data) = await _restClient.auth.get('/me');
      return Success(UserModel.fromMap(data));
    } on DioException catch (e, s) {
      log('Erro ao buscar usuário logado', error: e, stackTrace: s);
      return Failure(
        const RepositoryException(message: 'Erro ao buscar usuário logado'),
      );
    } on ArgumentError catch (e, s) {
      log('Invalid JSON', error: e, stackTrace: s);
      return Failure(const RepositoryException(message: 'Invalid JSON'));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> registerAdmin(
    ({String email, String name, String password}) userData,
  ) async {
    try {
      await _restClient.unAuth.post(
        '/users',
        data: {
          'name': userData.name,
          'email': userData.email,
          'password': userData.password,
          'profile': 'ADM',
        },
      );
      return Success(nil);
    } on DioException catch (e, s) {
      log('Erro ao registrar usuário', error: e, stackTrace: s);
      return Failure(
        const RepositoryException(
          message: 'Erro ao registrar usuário adminstrador',
        ),
      );
    }
  }

  @override
  Future<Either<RepositoryException, List<UserModel>>> getEmployees(
    int barbeariapiId,
  ) async {
    try {
      final Response(:List data) = await _restClient.auth.get(
        '/users',
        queryParameters: {'barbeariapi_id': barbeariapiId},
      );
      final employees = data.map((e) => UserModelEmployee.fromMap(e)).toList();
      return Success(employees);
    } on DioException catch (e, s) {
      const errorMessage = 'Erro ao buscar colaboradores';
      log(errorMessage, error: e, stackTrace: s);
      return Failure(const RepositoryException(message: errorMessage));
    } on ArgumentError catch (e, s) {
      const errorMessage = 'Erro ao buscar colaboradores (Invalid JSON)';
      log(errorMessage, error: e, stackTrace: s);
      return Failure(const RepositoryException(message: errorMessage));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> registerADMAsEmployee(
    ({List<int> workHours, List<String> workDays}) userModel,
  ) async {
    try {
      final userModelResult = await me();

      final int userId;

      switch (userModelResult) {
        case Success(value: UserModel(:var id)):
          userId = id;
        case Failure(:var exception):
          return Failure(exception);
      }

      await _restClient.auth.put(
        '/users/$userId',
        data: {
          'work_days': userModel.workDays,
          'work_hours': userModel.workHours,
        },
      );

      return Success(nil);
    } on DioException catch (e, s) {
      const errorMessage = 'Erro ao inserir administrador como colaborador';
      log(errorMessage, error: e, stackTrace: s);
      return Failure(const RepositoryException(message: errorMessage));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> registerEmployee(
    ({
      int barbeariapiId,
      String email,
      String name,
      String password,
      List<String> workDays,
      List<int> workHours,
    })
    userModel,
  ) async {
    try {
      await _restClient.auth.post(
        '/users/',
        data: {
          'name': userModel.name,
          'email': userModel.email,
          'password': userModel.password,
          'work_days': userModel.workDays,
          'work_hours': userModel.workHours,
          'barbeariapi_id': userModel.barbeariapiId,
          'profile': 'EMPLOYEE',
        },
      );

      return Success(nil);
    } on DioException catch (e, s) {
      const errorMessage = 'Erro ao inserir colaborador';
      log(errorMessage, error: e, stackTrace: s);
      return Failure(const RepositoryException(message: errorMessage));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> updateUserData({
    required int userId,
    required String name,
    required String email,
    String? password,
    File? avatarFile,
  }) async {
    try {
      log('Iniciando atualização de usuário ID: $userId');

      // Preparar dados básicos sem a imagem
      final Map<String, dynamic> data = {'name': name, 'email': email};

      // Adicionar senha se fornecida
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }

      // Caso simples: quando não temos imagem para fazer upload
      if (avatarFile == null) {
        log('Atualizando apenas dados de texto (sem imagem)');
        final response = await _restClient.auth.put(
          '/users/$userId',
          data: data,
        );
        log('Resposta: ${response.statusCode}');
        return Success(nil);
      }

      // Quando temos imagem para upload
      try {
        // Verificar existência do arquivo
        if (!avatarFile.existsSync()) {
          log('Arquivo não existe: ${avatarFile.path}');
          return Failure(
            RepositoryException(message: 'Arquivo de imagem não encontrado'),
          );
        }

        final fileSize = await avatarFile.length();
        log('Tamanho do arquivo: ${fileSize} bytes');
        if (fileSize == 0) {
          log('Arquivo vazio');
          return Failure(
            RepositoryException(message: 'Arquivo de imagem vazio'),
          );
        }

        // Criar FormData com dados de texto e imagem
        final formData = FormData();

        // Adicionar campos de texto
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });

        // Obter extensão do arquivo
        final String extension = avatarFile.path.split('.').last.toLowerCase();
        final String mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

        // Adicionar imagem como parte do form
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(
              avatarFile.path,
              filename:
                  'avatar_${DateTime.now().millisecondsSinceEpoch}.$extension',
              contentType: MediaType.parse(mimeType),
            ),
          ),
        );

        log('FormData preparado, enviando requisição');

        // Configurar timeout dedicado para esse request específico
        final options = Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {'Accept': '*/*'},
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
          // Evitar que o Dio faça transformação automática nos dados
          listFormat: ListFormat.multiCompatible,
        );

        // Usar PUT para atualizar
        final response = await _restClient.auth.put(
          '/users/$userId',
          data: formData,
          options: options,
        );

        log('Upload concluído. Status: ${response.statusCode}');
        return Success(nil);
      } catch (e, s) {
        log('Erro específico no upload de imagem', error: e, stackTrace: s);
        if (e is DioException) {
          if (e.type == DioExceptionType.connectionTimeout) {
            return Failure(
              RepositoryException(
                message: 'Tempo esgotado ao conectar ao servidor',
              ),
            );
          } else if (e.response != null) {
            log('Resposta de erro: ${e.response?.data}');
          }
        }
        return Failure(
          RepositoryException(
            message: 'Erro ao fazer upload da imagem: ${e.toString()}',
          ),
        );
      }
    } on DioException catch (e, s) {
      final String errorMessage;
      if (e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Tempo limite esgotado na comunicação com o servidor';
      } else if (e.response != null) {
        errorMessage = 'Erro na requisição: ${e.response?.statusCode}';
        log('Resposta do servidor: ${e.response?.data}');
      } else {
        errorMessage = 'Erro de conexão com o servidor';
      }

      log(errorMessage, error: e, stackTrace: s);
      return Failure(RepositoryException(message: errorMessage));
    } catch (e, s) {
      final errorMessage = 'Erro inesperado: ${e.toString()}';
      log(errorMessage, error: e, stackTrace: s);
      return Failure(RepositoryException(message: errorMessage));
    }
  }
}
