import 'package:pi2/src/core/constants/constants.dart';
import 'package:pi2/src/core/providers/application_providers.dart';
import 'package:pi2/src/core/ui/barbeariapi_icons.dart';
import 'package:pi2/src/core/ui/widgets/barbeariapi_loader.dart';
import 'package:pi2/src/features/home/adm/home_adm_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key}) : hideFilter = true;
  const HomeHeader.withoutFilter({super.key}) : hideFilter = false;

  final bool hideFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barbeariapi = ref.watch(getMyBarbeariapiProvider);
    final userAsync = ref.watch(getMeProvider);

    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        image: DecorationImage(
          fit: BoxFit.cover,
          opacity: 0.5,
          image: AssetImage(AppImages.backgroundChair),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.maybeViewPaddingOf(context)?.top),
          barbeariapi.maybeWhen(
            orElse: () => const Center(child: BarbeariapiLoader()),
            data:
                (barbeariapi) => Row(
                  children: [
                    userAsync.maybeWhen(
                      data:
                          (user) => CircleAvatar(
                            backgroundColor: const Color(0xffbdbdbd),
                            backgroundImage:
                                user.avatar != null
                                    ? NetworkImage(user.avatar!)
                                    : const AssetImage(AppImages.avatar)
                                        as ImageProvider,
                          ),
                      orElse:
                          () => const CircleAvatar(
                            backgroundColor: Color(0xffbdbdbd),
                            child: SizedBox.shrink(),
                          ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        barbeariapi.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/user/edit');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Editar',
                        style: TextStyle(
                          color: AppColors.brown,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      alignment: Alignment.centerRight,
                      onPressed: () {
                        ref.read(homeADMVMProvider.notifier).logout();
                      },
                      icon: const Icon(
                        BarbeariapiIcons.exit,
                        color: AppColors.brown,
                        size: 32,
                      ),
                    ),
                  ],
                ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Bem-vindo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Agende um Cliente',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 40,
            ),
          ),
          Offstage(offstage: hideFilter, child: const SizedBox(height: 24)),
          Offstage(
            offstage: hideFilter,
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Buscar colaborador',
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 24),
                  child: Icon(BarbeariapiIcons.search, color: AppColors.brown),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
