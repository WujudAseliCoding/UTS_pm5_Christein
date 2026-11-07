import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';
import 'app_components.dart';

/// Shared confirmation dialog for exit, finish, replace and clear actions.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Ya, lanjutkan',
  String cancelLabel = 'Batal',
  bool destructive = false,
  IconData icon = Icons.help_outline_rounded,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      final palette = dialogContext.palette;
      final scheme = Theme.of(dialogContext).colorScheme;
      final maxWidth = (MediaQuery.sizeOf(dialogContext).width * 0.9).clamp(
        280.0,
        430.0,
      );
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: dialogContext.rs(20),
          vertical: dialogContext.rs(24),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: AppCard(
            showShadow: true,
            padding: EdgeInsets.all(dialogContext.rs(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: dialogContext.rs(46),
                  height: dialogContext.rs(46),
                  decoration: BoxDecoration(
                    color: destructive
                        ? palette.softDanger
                        : palette.softPrimary,
                    borderRadius: BorderRadius.circular(
                      dialogContext.rs(14),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: destructive
                        ? scheme.error
                        : scheme.primary,
                    size: dialogContext.rs(24),
                  ),
                ),
                SizedBox(height: dialogContext.rs(16)),
                Text(
                  title,
                  style: Theme.of(dialogContext).textTheme.titleLarge,
                ),
                SizedBox(height: dialogContext.rs(8)),
                Text(
                  message,
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                    color: palette.mutedText,
                  ),
                ),
                SizedBox(height: dialogContext.rs(22)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Flexible(
                      child: AppButton(
                        label: cancelLabel,
                        variant: AppButtonVariant.ghost,
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        compact: true,
                      ),
                    ),
                    SizedBox(width: dialogContext.rs(8)),
                    Flexible(
                      child: AppButton(
                        label: confirmLabel,
                        variant: destructive
                            ? AppButtonVariant.danger
                            : AppButtonVariant.primary,
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  IconData icon = Icons.info_outline_rounded,
  bool isError = false,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(
              icon,
              color: isError ? Colors.white : Colors.white,
              size: context.rs(20),
            ),
            SizedBox(width: context.rs(10)),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
}
