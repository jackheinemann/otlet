import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/ui/screens/settings/licenses_screen.dart';
import 'package:otlet/ui/widgets/alerts/confirm_dialog.dart';

class SettingsScreen extends StatefulWidget {
  final OtletInstance instance;

  SettingsScreen(this.instance);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  OtletInstance instance;

  @override
  void initState() {
    super.initState();
    instance = widget.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              onTap: () async {
                bool shouldWipe = await showConfirmDialog(
                    'Permanently wipe all of your data?', context);
                if (!shouldWipe) return;
                Navigator.pop(context, true);
              },
              title: Text('Clear all data'),
              trailing: Icon(Icons.delete_forever),
            ),
            ListTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LicensesScreen())),
                title: Text('View credits and licenses'),
                trailing: Icon(Icons.copyright)),
            ListTile(
                onTap: () async {
                  final bool available =
                      await InAppPurchase.instance.isAvailable();
                  if (!available) {
                    // The store cannot be reached or accessed. Update the UI accordingly.
                    print('unavailable');
                  }
                },
                title: Text('Donate'),
                trailing: Icon(Icons.money))
          ],
        ),
      ),
    );
  }
}
