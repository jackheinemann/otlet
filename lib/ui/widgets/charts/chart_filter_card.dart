import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/chart_helpers.dart';
import 'package:otlet/ui/widgets/alerts/confirm_dialog.dart';

class ChartFilterCard extends StatelessWidget {
  final ChartFilter filter;
  final VoidCallback editFilter;
  final VoidCallback deleteFilter;
  ChartFilterCard(this.filter,
      {@required this.editFilter, @required this.deleteFilter});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        // set up edit
        editFilter();
      },
      title: Text(filter.filterLabel(), style: TextStyle(fontSize: 17)),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          // check for delete
          bool shouldDelete = await showConfirmDialog(
              'Delete filter ${filter.filterLabel()}?', context);
          if (!shouldDelete) return;
          deleteFilter();
        },
      ),
    );
  }
}
