class DropdownItem {
  final String value;
  final String label;

  DropdownItem({required this.value, required this.label});
}

class DropdownGroupItem {
  final String label;
  final List<DropdownItem> children;

  DropdownGroupItem({required this.label, required this.children});
}
