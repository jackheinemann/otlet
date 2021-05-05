import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, String title) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text('Ok'))
            ],
          ));
}
