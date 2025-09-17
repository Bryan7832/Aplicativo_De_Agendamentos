import 'package:flutter/widgets.dart';

final class BarbeariapiNavGlobalKey {
  BarbeariapiNavGlobalKey._();

  final navKey = GlobalKey<NavigatorState>();

  static BarbeariapiNavGlobalKey? _instance;
  static BarbeariapiNavGlobalKey get instance =>
      _instance ??= BarbeariapiNavGlobalKey._();
}
