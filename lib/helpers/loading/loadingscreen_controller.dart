import 'package:flutter/cupertino.dart';

typedef Closeloadingscreen = bool Function();
typedef Updateloadingscreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final Closeloadingscreen close;
  final Updateloadingscreen update;

  const LoadingScreenController({
    required this.close,
    required this.update,
  });
}
