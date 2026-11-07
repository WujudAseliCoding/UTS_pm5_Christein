import 'package:flutter/material.dart';

import '../../screens/home_page.dart';
import '../../screens/quiz_page.dart';
import '../../screens/result_page.dart';
import '../../screens/review_page.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String quiz = '/quiz';
  static const String result = '/result';
  static const String review = '/review';
}

/// Named-route navigation with a subtle shared transition between pages.
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      AppRoutes.quiz => const QuizPage(),
      AppRoutes.result => const ResultPage(),
      AppRoutes.review => const ReviewPage(),
      _ => const HomePage(),
    };

    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 340),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.disableAnimationsOf(context)) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.035),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
