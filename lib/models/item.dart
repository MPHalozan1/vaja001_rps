class Item {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final int totalQuantity;
  int availableQuantity;
  final double pricePerDay;
  final double purchaseCost;
  final Map<String, String> specs;
  bool isDamaged;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.totalQuantity,
    required this.availableQuantity,
    this.pricePerDay = 0.0,
    this.purchaseCost = 0.0,
    this.specs = const {},
    this.isDamaged = false,
  });
}
