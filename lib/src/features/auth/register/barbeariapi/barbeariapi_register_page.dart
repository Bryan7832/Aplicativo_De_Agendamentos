import 'package:pi2/src/core/fp/nil.dart';
import 'package:pi2/src/core/ui/helpers/form_helper.dart';
import 'package:pi2/src/core/ui/helpers/messages.dart';
import 'package:pi2/src/core/ui/widgets/hours_panel.dart';
import 'package:pi2/src/core/ui/widgets/weekdays_panel.dart';
import 'package:pi2/src/features/auth/register/barbeariapi/barbeariapi_register_status.dart';
import 'package:pi2/src/features/auth/register/barbeariapi/barbeariapi_register_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:validatorless/validatorless.dart';

final class BarbeariapiRegisterPage extends ConsumerStatefulWidget {
  const BarbeariapiRegisterPage({super.key});

  @override
  ConsumerState<BarbeariapiRegisterPage> createState() =>
      _BarbeariapiRegisterPageState();
}

final class _BarbeariapiRegisterPageState
    extends ConsumerState<BarbeariapiRegisterPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BarbeariapiRegisterVM(
      :addOrRemoveOpeningDays,
      :addOrRemoveOpeningHours,
      :register,
    ) = ref.watch(barbeariapiRegisterVMProvider.notifier);

    ref.listen(
      barbeariapiRegisterVMProvider,
      (_, state) => switch (state.status) {
        BarbeariapiRegisterStateStatus.initial => nil,
        BarbeariapiRegisterStateStatus.error => context.showError(
          'Erro ao cadastrar estabelecimento',
        ),
        BarbeariapiRegisterStateStatus.success => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home/adm', (_) => false),
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar estabelecimento')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 5),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(label: Text('Nome')),
              onTapOutside: (_) => context.unfocus(),
              validator: Validatorless.required('Nome obrigatório'),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(label: Text('E-mail')),
              onTapOutside: (_) => context.unfocus(),
              keyboardType: TextInputType.emailAddress,
              validator: Validatorless.multiple([
                Validatorless.required('E-mail obrigatório'),
                Validatorless.email('E-mail inválido'),
              ]),
            ),
            const SizedBox(height: 24),
            WeekdaysPanel(onDayPressed: addOrRemoveOpeningDays),
            const SizedBox(height: 24),
            HoursPanel(
              startTime: 6,
              endTime: 23,
              onTimePressed: addOrRemoveOpeningHours,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed:
                  () => switch (formKey.currentState?.validate()) {
                    false || null => context.showError('Formulário inválido'),
                    true => register(
                      name: nameController.text,
                      email: emailController.text,
                    ),
                  },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('Cadastrar estabelecimento'),
            ),
          ],
        ),
      ),
    );
  }
}
