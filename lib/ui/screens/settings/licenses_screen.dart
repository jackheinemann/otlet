import 'package:flutter/material.dart';
import 'package:otlet/business_logic/utils/constants.dart';

class LicensesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Credits and Licenses')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: packageLicenses.length,
          itemBuilder: (context, i) {
            MapEntry licenseEntry = packageLicenses.entries.elementAt(i);
            String packageName = licenseEntry.key;
            String packageLicenseText = licenseEntry.value;

            return ListTile(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text('$packageName License'),
                          content: SingleChildScrollView(
                            child: Text(
                              packageLicenseText,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          actions: [
                            Center(
                              child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Done')),
                            )
                          ],
                        ));
              },
              title: Text(packageName),
              trailing: Icon(Icons.zoom_in),
            );
          },
        ),
      ),
    );
  }
}
