import 'package:flutter/material.dart';

class UIHelpers {
  // Private constructor to prevent instantiation
  UIHelpers._();

  // Show a generic snackbar
  static void showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Show an error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, Colors.red);
  }

  // Show a success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, Colors.green);
  }

  // Show a confirmation dialog
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              ElevatedButton(
                onPressed: () {
                  onConfirm();
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }

  // Build complete address from components
  static String buildCompleteAddress({
    required String street,
    required String ward,
    required String district,
    String? city,
  }) {
    final List<String> addressParts = [];

    if (street.isNotEmpty) addressParts.add(street);
    if (ward.isNotEmpty) addressParts.add(ward);
    if (district.isNotEmpty) addressParts.add(district);
    if (city != null && city.isNotEmpty) addressParts.add(city);

    return addressParts.join(', ');
  }
}
