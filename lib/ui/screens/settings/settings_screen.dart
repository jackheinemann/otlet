import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/screens/general/collections_selector.dart';
import 'package:otlet/ui/widgets/alerts/confirm_dialog.dart';

class SettingsScreen extends StatefulWidget {
  final OtletInstance instance;
  final Function(int) updateScreenIndex;
  SettingsScreen(this.instance, {@required this.updateScreenIndex});
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  OtletInstance instance;

  int settingsScreenIndex = 0;

  @override
  void initState() {
    super.initState();
    instance = widget.instance;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (settingsScreenIndex == 0)
          widget.updateScreenIndex(ScreenIndex.mainTabs);
        else if (settingsScreenIndex == 1) {
          bool shouldPop = await showConfirmDialog(
              'Discard changes to Collections?', context);
          if (shouldPop)
            setState(() {
              settingsScreenIndex = 0;
            });
        }

        return Future.value(false);
      },
      child: settingsScreenIndex == 0
          ? Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: backButton(),
                    onPressed: () =>
                        widget.updateScreenIndex(ScreenIndex.mainTabs)),
                centerTitle: true,
                title: Text('Settings'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // ListTile(
                    //     onTap: () => Navigator.push(context,
                    //         MaterialPageRoute(builder: (context) => LicensesScreen())),
                    //     title: Text('View credits and licenses'),
                    //     trailing: Icon(Icons.copyright)),
                    ListTile(
                      title: Text('Manage collections'),
                      onTap: () {
                        setState(() {
                          settingsScreenIndex = 1;
                        });
                      },
                      trailing: Icon(Icons.list),
                    ),
                    ListTile(
                      onTap: () async {
                        bool shouldWipe = await showConfirmDialog(
                            'Permanently wipe all of your data?', context);
                        if (!shouldWipe) return;
                        instance.scorchEarth();
                        widget.updateScreenIndex(0);
                      },
                      title: Text('Clear all data'),
                      trailing: Icon(Icons.delete_forever),
                    ),
                  ],
                ),
              ),
            )
          : CollectionsSelector(
              options: instance.generateBookCollections(),
              instance: instance,
              title: 'Manage Collections',
              isBookScope: false,
              updateAddIndex: (index, {options}) {
                setState(() {
                  setState(() {
                    settingsScreenIndex = 0;
                  });
                });
              }),
    );
  }
}
