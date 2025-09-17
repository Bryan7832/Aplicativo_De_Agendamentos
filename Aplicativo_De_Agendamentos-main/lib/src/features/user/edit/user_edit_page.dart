import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pi2/src/core/providers/application_providers.dart';
import 'package:pi2/src/core/ui/helpers/form_helper.dart';
import 'package:pi2/src/core/ui/helpers/messages.dart';
import 'package:pi2/src/features/user/edit/user_edit_vm.dart';
import 'package:pi2/src/models/user_model.dart';
import 'package:validatorless/validatorless.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pi2/src/core/constants/constants.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class UserEditPage extends ConsumerStatefulWidget {
  const UserEditPage({super.key});

  @override
  ConsumerState<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends ConsumerState<UserEditPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final barbeariapiNameController = TextEditingController();
  bool isLoading = false;
  int? barbeariapiId;
  bool isAdmin = false;
  File? imageFile; // Para a imagem selecionada

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userModel = await ref.read(getMeProvider.future);
      if (!mounted) return;

      print('Usuário carregado: ${userModel.name} (${userModel.profile})');
      nameController.text = userModel.name;
      emailController.text = userModel.email;

      // Verifica se é um administrador
      isAdmin = userModel is UserModelADM;
      print('Usuário é admin? $isAdmin');

      // Se for admin, carrega dados da barbearia
      if (isAdmin) {
        try {
          print('Tentando carregar dados da barbearia...');
          final barbeariapiAsync = await ref.read(
            getMyBarbeariapiProvider.future,
          );
          if (!mounted) return;

          print(
            'Barbearia carregada: ${barbeariapiAsync.name}, ID: ${barbeariapiAsync.id}',
          );
          barbeariapiNameController.text = barbeariapiAsync.name;
          barbeariapiId = barbeariapiAsync.id;
          setState(() {}); // Atualiza a UI para mostrar o campo
        } catch (e) {
          print('Erro ao carregar dados da barbearia: $e');
          setState(() {});
        }
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();

      // Mostrar diálogo de seleção de origem
      final source = await showDialog<ImageSource>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Selecionar imagem'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Galeria'),
                    onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Câmera'),
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                  ),
                ],
              ),
            ),
      );

      if (source == null) return;

      final pickedFile = await picker.pickImage(
        source: source,
        // Tamanho e qualidade otimizados
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() => isLoading = true);

        try {
          final file = File(pickedFile.path);
          final fileSize = await file.length();

          if (fileSize > 5 * 1024 * 1024) {
            setState(() => isLoading = false);
            if (!mounted) return;
            context.showError(
              'Imagem muito grande. Selecione uma imagem menor que 5MB.',
            );
            return;
          }

          setState(() {
            imageFile = file;
            isLoading = false;
          });
        } catch (e) {
          setState(() => isLoading = false);
          print('Erro ao processar imagem: $e');
          context.showError('Erro ao processar a imagem');
        }
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      context.showError('Erro ao selecionar a imagem');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    barbeariapiNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEditVM = ref.watch(userEditVMProvider.notifier);

    ref.listen(userEditVMProvider, (previous, current) {
      switch (current) {
        case UserEditState.initial:
          break;
        case UserEditState.loading:
          setState(() => isLoading = true);
          break;
        case UserEditState.success:
          setState(() => isLoading = false);
          context.showSuccess('Dados atualizados com sucesso!');
          Navigator.of(context).pop();
          break;
        case UserEditState.error:
          setState(() => isLoading = false);
          context.showError('Erro ao atualizar dados do usuário');
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body:
          isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processando...', style: TextStyle(fontSize: 16)),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: ListView(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                                image:
                                    imageFile != null
                                        ? DecorationImage(
                                          image: FileImage(imageFile!),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              ),
                              child:
                                  imageFile == null
                                      ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      )
                                      : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: AppColors.brown,
                                    width: 2,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: AppColors.brown,
                                  ),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(label: Text('Nome')),
                        onTapOutside: (_) => context.unfocus(),
                        validator: Validatorless.required('Nome obrigatório'),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          label: Text('E-mail'),
                        ),
                        onTapOutside: (_) => context.unfocus(),
                        validator: Validatorless.multiple([
                          Validatorless.required('E-mail obrigatório'),
                          Validatorless.email('E-mail inválido'),
                        ]),
                      ),

                      // Campo para nome da barbearia (apenas para admins)
                      if (isAdmin) ...[
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: barbeariapiNameController,
                          decoration: const InputDecoration(
                            label: Text('Nome da Barbearia(op)'),
                          ),
                          onTapOutside: (_) => context.unfocus(),

                          // validator: Validatorless.required(
                          //   'Nome da barbearia obrigatório',
                        ),
                      ],

                      const SizedBox(height: 24),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          label: Text('Nova senha (opcional)'),
                        ),
                        obscureText: true,
                        onTapOutside: (_) => context.unfocus(),
                        validator:
                            passwordController.text.isNotEmpty
                                ? Validatorless.min(
                                  6,
                                  'Senha deve ter no mínimo 6 caracteres',
                                )
                                : null,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: confirmPasswordController,
                        decoration: const InputDecoration(
                          label: Text('Confirmar nova senha'),
                        ),
                        obscureText: true,
                        onTapOutside: (_) => context.unfocus(),
                        validator:
                            passwordController.text.isNotEmpty
                                ? Validatorless.multiple([
                                  Validatorless.required(
                                    'Confirmação de senha obrigatória',
                                  ),
                                  Validatorless.compare(
                                    passwordController,
                                    'Senhas não conferem',
                                  ),
                                ])
                                : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed:
                            isLoading
                                ? null // Desabilitar o botão durante carregamento
                                : () {
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    setState(
                                      () => isLoading = true,
                                    ); // Mostrar loading

                                    userEditVM.updateUserData(
                                      name: nameController.text,
                                      email: emailController.text,
                                      password:
                                          passwordController.text.isEmpty
                                              ? null
                                              : passwordController.text,
                                      barbeariapiId:
                                          isAdmin ? barbeariapiId : null,
                                      barbeariapiName:
                                          isAdmin
                                              ? barbeariapiNameController.text
                                              : null,
                                      imageFile: imageFile,
                                    );
                                  } else {
                                    context.showError('Formulário inválido');
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                        ),
                        child: const Text('SALVAR ALTERAÇÕES'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
