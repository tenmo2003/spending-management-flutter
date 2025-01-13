import 'package:flutter/material.dart';
import 'package:spending_management_app/model/group_item.dart';

class GroupedDropdownButton extends StatelessWidget {
  final String selectedItemValue;
  final List<DropdownGroupItem> items;
  final int groupNameFontSize;
  final int itemFontSize;
  final Function(String?)? onChanged;

  const GroupedDropdownButton(
      {super.key,
      required this.items,
      this.groupNameFontSize = 18,
      this.itemFontSize = 14,
      required this.onChanged,
      required this.selectedItemValue});
  @override
  Widget build(BuildContext context) {
    final displayItems = <_GroupedDropdownElement>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      displayItems.add(
          _GroupedDropdownElement(label: item.label, displayType: "group"));

      for (int j = 0; j < item.children.length; j++) {
        final subItem = item.children[j];
        displayItems.add(_GroupedDropdownElement(
            label: subItem.label, value: subItem.value, displayType: "item"));
      }
    }

    return DropdownButton<String>(
      value: selectedItemValue,
      items: displayItems
          .map((item) => DropdownMenuItem<String>(
                value: item.value,
                enabled: item.displayType == "item",
                child: Container(
                    decoration: BoxDecoration(
                      color:
                          item.displayType == "group" ? Colors.grey[200] : null,
                    ),
                    child: Text(item.label,
                        style: item.displayType == "group"
                            ? TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: groupNameFontSize.toDouble(),
                              )
                            : TextStyle(
                                fontSize: itemFontSize.toDouble(),
                              ))),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _GroupedDropdownElement {
  final String label;
  final String? value;
  final String displayType;

  _GroupedDropdownElement(
      {required this.label, this.value, required this.displayType});
}
