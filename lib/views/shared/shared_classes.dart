class MenuItem {
  final String icon;
  final String title;
  final String? description;
  final String? endElement;

  MenuItem({
    required this.icon,
    required this.title,
    this.description,
    this.endElement,
  });
}

class MenuSection {
  final String? title;
  final List<MenuItem> items;

  MenuSection({required this.title, required this.items});
}