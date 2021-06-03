import 'package:flutter/material.dart';

Future<String> showInputDialog(BuildContext context, String title,
    {String initialValue, String labelText, String submitText}) async {
  TextEditingController inputController = TextEditingController();
  String input = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: TextFormField(
              keyboardType: TextInputType.numberWithOptions(signed: true),
              controller: inputController,
              decoration: InputDecoration(
                  labelText: labelText, border: OutlineInputBorder()),
            ),
            actions: [
              TextButton(
                  onPressed: () =>
                      Navigator.pop(context, inputController.text.trim()),
                  child: Text(submitText ?? 'Ok'))
            ],
          ));
  return input;
}
