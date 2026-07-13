import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/themes/app_theme.dart';

class PurwaDigitalApp extends ConsumerWidget {
  const PurwaDigitalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Purwa Digital',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: ref.watch(appRouterProvider),
      );
}
