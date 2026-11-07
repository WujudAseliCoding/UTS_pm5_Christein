import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'state/history_controller.dart';
import 'state/quiz_controller.dart';
import 'state/theme_controller.dart';

/// Root widget. Controllers are injected so tests and the app share the exact
/// same composition without hidden global state.
class KuisCendekiaApp extends StatelessWidget {
  const KuisCendekiaApp({
    super.key,
    required this.themeController,
    required this.historyController,
    required this.quizController,
  });

  final ThemeController themeController;
  final HistoryController historyController;
  final QuizController quizController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
        ChangeNotifierProvider<HistoryController>.value(
          value: historyController,
        ),
        ChangeNotifierProvider<QuizController>.value(value: quizController),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Kuis Cendekia',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.mode,
            themeAnimationDuration: const Duration(milliseconds: 280),
            scrollBehavior: const _AppScrollBehavior(),
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRouter.onGenerateRoute,
            builder: (context, child) {
              final baseTheme = Theme.of(context);
              final width = MediaQuery.sizeOf(context).width;
              return Theme(
                data: AppTheme.withResponsiveTypography(baseTheme, width),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}

/// Allows history lists to be dragged with a mouse on web/desktop.
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
