import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';
import '../state/theme_controller.dart';

/// The app's original SVG mark.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? context.rs(42);
    return Semantics(
      image: true,
      label: 'Logo Kuis Cendekia',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(dimension * 0.28),
        child: SvgPicture.asset(
          'assets/images/logo_mark.svg',
          width: dimension,
          height: dimension,
        ),
      ),
    );
  }
}

/// Header used by all pages. Home shows the brand, inner pages show a title
/// and a back button.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.actions = const <Widget>[],
    this.showThemeButton = true,
  });

  final String? title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool showThemeButton;

  @override
  Widget build(BuildContext context) {
    final isBrand = title == null;
    return Row(
      children: <Widget>[
        if (showBack) ...<Widget>[
          AppIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Kembali',
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          SizedBox(width: context.rs(12)),
        ],
        if (isBrand) ...<Widget>[
          const AppLogo(),
          SizedBox(width: context.rs(12)),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Kuis Cendekia',
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (constraints.maxWidth > context.rs(180))
                      Text(
                        subtitle ?? 'Tantang wawasanmu',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.palette.mutedText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                );
              },
            ),
          ),
        ] else
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.palette.mutedText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        if (actions.isNotEmpty) ...<Widget>[
          SizedBox(width: context.rs(8)),
          ...actions,
        ],
        if (showThemeButton) ...<Widget>[
          SizedBox(width: context.rs(8)),
          const ThemeModeButton(),
        ],
      ],
    );
  }
}

/// Compact icon button with a consistent tap target and surface.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.filled = true,
    this.foregroundColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool filled;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final size = context.rs(44).clamp(40.0, 50.0);
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: size * 0.5),
      color: foregroundColor,
      style: IconButton.styleFrom(
        minimumSize: Size.square(size),
        maximumSize: Size.square(size),
        padding: EdgeInsets.zero,
        backgroundColor: filled
            ? Theme.of(context).colorScheme.surface
            : Colors.transparent,
        side: filled
            ? BorderSide(color: context.palette.cardBorder)
            : BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size * 0.34),
        ),
      ),
    );
  }
}

/// Pick system, light or dark mode. Selection is persisted by
/// [ThemeController].
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final brightness = Theme.of(context).brightness;
    final icon = switch (controller.mode) {
      ThemeMode.system => brightness == Brightness.dark
          ? Icons.brightness_auto_rounded
          : Icons.brightness_auto_outlined,
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
    };

    return PopupMenuButton<ThemeMode>(
      key: const Key('theme-menu'),
      tooltip: 'Ubah tema',
      initialValue: controller.mode,
      onSelected: controller.setMode,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => <PopupMenuEntry<ThemeMode>>[
        for (final mode in ThemeMode.values)
          PopupMenuItem<ThemeMode>(
            value: mode,
            child: Row(
              children: <Widget>[
                Icon(
                  switch (mode) {
                    ThemeMode.system => Icons.brightness_auto_rounded,
                    ThemeMode.light => Icons.light_mode_rounded,
                    ThemeMode.dark => Icons.dark_mode_rounded,
                  },
                  size: context.rs(20),
                  color: controller.mode == mode
                      ? Theme.of(context).colorScheme.primary
                      : context.palette.mutedText,
                ),
                SizedBox(width: context.rs(10)),
                Text(
                  switch (mode) {
                    ThemeMode.system => 'Ikuti sistem',
                    ThemeMode.light => 'Mode terang',
                    ThemeMode.dark => 'Mode gelap',
                  },
                ),
                const Spacer(),
                if (controller.mode == mode)
                  Icon(
                    Icons.check_rounded,
                    size: context.rs(18),
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
      ],
      child: Container(
        width: context.rs(44).clamp(40.0, 50.0),
        height: context.rs(44).clamp(40.0, 50.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: context.palette.cardBorder),
          borderRadius: BorderRadius.circular(context.rs(15)),
        ),
        child: Icon(icon, size: context.rs(21)),
      ),
    );
  }
}
