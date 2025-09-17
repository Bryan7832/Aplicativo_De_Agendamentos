import 'dart:developer';
import 'dart:io';

import 'package:pi2/src/core/fp/either.dart';
import 'package:pi2/src/core/providers/application_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_edit_vm.g.dart';

enum UserEditState { initial, loading, success, error }

@riverpod
class UserEditVM extends _$UserEditVM {
  UserEditState build() => UserEditState.initial;

  Future<void> updateUserData({
    required String name,
    required String email,
    String? password,
    int? barbeariapiId,
    String? barbeariapiName,
    File? imageFile,
  }) async {
    try {
      state = UserEditState.loading;
      log('Iniciando atualização de dados do usuário');

      // Obter referências para repositories
      final userRepository = ref.read(userRepositoryProvider);
      final userModel = await ref.read(getMeProvider.future);

      // Log para diagnóstico da imagem
      if (imageFile != null) {
        log(
          'Imagem selecionada: ${imageFile.path}, tamanho: ${await imageFile.length()} bytes',
        );
        if (!imageFile.existsSync()) {
          log('ATENÇÃO: O arquivo não existe no caminho informado');
        }
      }

      // Atualizar dados do usuário (incluindo imagem se fornecida)
      final userResult = await userRepository.updateUserData(
        userId: userModel.id,
        name: name,
        email: email,
        password: password,
        avatarFile: imageFile,
      );

      // Verificar resultado da atualização do usuário
      if (userResult case Failure(:var exception)) {
        log('Erro ao atualizar dados do usuário: ${exception.message}');
        state = UserEditState.error;
        return;
      }

      log('Dados do usuário atualizados com sucesso');

      // Atualizar dados da barbearia (se for administrador)
      if (barbeariapiId != null && barbeariapiName != null) {
        log('Atualizando nome da barbearia para: $barbeariapiName');

        final barbeariapiRepository = ref.read(barbeariapiRepositoryProvider);
        final barbeariapiResult = await barbeariapiRepository.updateBarbeariapi(
          barbeariapiId: barbeariapiId,
          name: barbeariapiName,
        );

        if (barbeariapiResult case Failure(:var exception)) {
          log('Erro ao atualizar nome da barbearia: ${exception.message}');
          state = UserEditState.error;
          return;
        }

        log('Dados da barbearia atualizados com sucesso');
      }

      // Invalidar providers para recarregar dados
      ref.invalidate(getMeProvider);
      ref.invalidate(getMyBarbeariapiProvider);
      log('Providers invalidados para refresh dos dados');

      state = UserEditState.success;
    } catch (e, s) {
      log('Erro não tratado ao atualizar dados', error: e, stackTrace: s);
      state = UserEditState.error;
    }
  }
}
