import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';

class AppUtils {
  // Date and Time formatting
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }

  static String formatEventTime(DateTime startTime, DateTime endTime) {
    final startStr = formatTime(startTime);
    final endStr = formatTime(endTime);

    if (startTime.day == endTime.day) {
      return '${formatDate(startTime)} • $startStr - $endStr';
    } else {
      return '${formatDateTime(startTime)} - ${formatDateTime(endTime)}';
    }
  }

  // URL and sharing utilities
  static Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  static Future<void> launchEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters({
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch email');
    }
  }

  static Future<void> launchPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch phone');
    }
  }

  static Future<void> launchMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final query = label != null
        ? Uri.encodeComponent(label)
        : '$latitude,$longitude';
    final uri = Uri.parse('https://maps.google.com/maps?q=$query');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch maps');
    }
  }

  static Future<void> shareText(String text) async {
    await Share.share(text);
  }

  static Future<void> shareEvent({
    required String eventTitle,
    required String eventUrl,
    String? eventDescription,
  }) async {
    final text =
        '''
Check out this event: $eventTitle

${eventDescription ?? ''}

$eventUrl

Shared via SomethingToDo
    '''
            .trim();

    await Share.share(text);
  }

  // Validation utilities
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phone);
  }

  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // UI utilities
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppTheme.errorColor);
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppTheme.successColor);
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // String utilities
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String formatCurrency(double amount, {String currency = 'USD'}) {
    if (amount == 0) return 'Free';
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    ).format(amount);
  }

  // Color utilities
  static Color getContrastColor(Color backgroundColor) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return brightness == Brightness.light ? Colors.black : Colors.white;
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  // List utilities
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<List<T>> chunk<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }

  // Helper method for encoding query parameters
  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  // Platform utilities
  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  // Animation utilities
  static Widget fadeInWidget(
    Widget child, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }

  static Widget slideInWidget(
    Widget child, {
    Duration duration = const Duration(milliseconds: 300),
    Offset begin = const Offset(0.0, 1.0),
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: begin, end: Offset.zero),
      duration: duration,
      builder: (context, value, child) =>
          Transform.translate(offset: value, child: child),
      child: child,
    );
  }

  // Distance formatting
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }

  // Event status utilities
  static bool isEventLive(DateTime startTime, DateTime endTime) {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  static bool isEventUpcoming(DateTime startTime) {
    return DateTime.now().isBefore(startTime);
  }

  static bool isEventPast(DateTime endTime) {
    return DateTime.now().isAfter(endTime);
  }

  // Search utilities
  static List<String> generateSearchKeywords(String text) {
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    final keywords = <String>{};

    for (final word in words) {
      if (word.length > 2) {
        keywords.add(word);
        // Add partial matches
        for (int i = 3; i <= word.length; i++) {
          keywords.add(word.substring(0, i));
        }
      }
    }

    return keywords.toList();
  }
}
