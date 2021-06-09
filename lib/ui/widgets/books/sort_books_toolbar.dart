import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/ui/widgets/alerts/collection_selector.dart';
import 'package:provider/provider.dart';

class SortBooksToolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(
      builder: (context, instance, _) => GestureDetector(
        onTap: () async {
          List<String> selected = await showCollectionSelectorDialog(
              context,
              'Display books from:',
              instance.collections,
              instance.selectedCollections);
          instance.updateSelectedCollection(selected);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                  instance.selectedCollections.isEmpty
                      ? 'Filter by collection'
                      : instance.selectedCollections.join(', '),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                  )),
            ),
            Icon(Icons.arrow_drop_down)
          ],
        ),
      ),
    );
  }
}
