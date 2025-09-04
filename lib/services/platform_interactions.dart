import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PlatformInteractions {
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  // Platform-specific haptic feedback
  static void lightImpact() {
    if (isIOS) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  static void mediumImpact() {
    if (isIOS) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  static void heavyImpact() {
    if (isIOS) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  // Platform-specific bottom sheets
  static Future<T?> showPlatformBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    double? heightFactor,
  }) {
    if (isIOS) {
      return showCupertinoModalBottomSheet<T>(
        context: context,
        builder: (context) => child,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        topRadius: const Radius.circular(20),
        backgroundColor: Colors.transparent,
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        builder: (context) => child,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      );
    }
  }

  // Platform-specific action sheets
  static Future<T?> showPlatformActionSheet<T>({
    required BuildContext context,
    required String title,
    required List<PlatformAction> actions,
    String? message,
    bool showCancel = true,
  }) {
    if (isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: Text(title),
          message: message != null ? Text(message) : null,
          actions: actions.map((action) {
            return CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                action.onPressed();
              },
              isDestructiveAction: action.isDestructive,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (action.icon != null) ...[
                    Icon(
                      action.icon,
                      color: action.isDestructive ? Colors.red : null,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(action.title),
                ],
              ),
            );
          }).toList(),
          cancelButton: showCancel
              ? CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                )
              : null,
        ),
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Actions
              ...actions.map((action) {
                return ListTile(
                  leading: action.icon != null
                      ? Icon(
                          action.icon,
                          color: action.isDestructive ? Colors.red : null,
                        )
                      : null,
                  title: Text(
                    action.title,
                    style: TextStyle(
                      color: action.isDestructive ? Colors.red : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    action.onPressed();
                  },
                );
              }),
              if (showCancel) ...[
                const Divider(),
                ListTile(
                  title: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ],
          ),
        ),
      );
    }
  }

  // Platform-specific transitions
  static PageRouteBuilder<T> createPlatformRoute<T>({
    required Widget page,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    if (isIOS) {
      return PageRouteBuilder<T>(
        settings: settings,
        fullscreenDialog: fullscreenDialog,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    } else {
      return PageRouteBuilder<T>(
        settings: settings,
        fullscreenDialog: fullscreenDialog,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
      );
    }
  }

  // Platform-specific toast notifications
  static void showToast({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 60,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? Colors.black87,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  // Platform-specific scroll physics
  static ScrollPhysics get platformScrollPhysics {
    if (isIOS) {
      return const BouncingScrollPhysics();
    } else {
      return const ClampingScrollPhysics();
    }
  }

  // Platform-specific ripple effect
  static Widget buildPlatformInkWell({
    required Widget child,
    required VoidCallback onTap,
    BorderRadius? borderRadius,
    Color? splashColor,
    Color? highlightColor,
  }) {
    if (isAndroid) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: splashColor,
          highlightColor: highlightColor,
          child: child,
        ),
      );
    } else {
      return GestureDetector(onTap: onTap, child: child);
    }
  }
}

class PlatformAction {
  final String title;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isDestructive;

  const PlatformAction({
    required this.title,
    required this.onPressed,
    this.icon,
    this.isDestructive = false,
  });
}

// Platform-specific loading indicator
class PlatformLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? strokeWidth;

  const PlatformLoadingIndicator({super.key, this.color, this.strokeWidth});

  @override
  Widget build(BuildContext context) {
    if (PlatformInteractions.isIOS) {
      return CupertinoActivityIndicator(color: color ?? Colors.white);
    } else {
      return CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth ?? 4.0,
      );
    }
  }
}

// Platform-specific switch
class PlatformSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const PlatformSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformInteractions.isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: activeColor,
      );
    } else {
      return Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: activeColor,
      );
    }
  }
}
