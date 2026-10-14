import 'package:flutter/material.dart';

/// Model posameznega kosa opreme v katalogu in skladišču
class Item {
  final String id;
  final String name;
  final String category;
  final String description;
  final double dailyRate; // Cena najema na dan (€)
  final double purchaseCost; // Nabavna vrednost za izračun ROI (€)
  final int totalStock; // Celotna zaloga
  final int availableStock; // Trenutno razpoložljiva zaloga
  final IconData icon;
  final Map<String, String> specs;
  final int totalRentalsCount; // Skupno število izposoj
  final double totalRevenueGenerated; // Skupni ustvarjeni prihodki (€)
  final bool underMaintenance; // Ali je artikel začasno v servisu

  const Item({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.dailyRate,
    required this.purchaseCost,
    required this.totalStock,
    required this.availableStock,
    this.icon = Icons.devices_other_rounded,
    this.specs = const {},
    this.totalRentalsCount = 0,
    this.totalRevenueGenerated = 0.0,
    this.underMaintenance = false,
  });

  /// Artikel je na voljo za izposojo, če je na zalogi in ni na servisu
  bool get isAvailable => availableStock > 0 && !underMaintenance;

  /// Čisti dobiček glede na nabavno vrednost (Prihodki - Nabavni strošek)
  double get netProfit => totalRevenueGenerated - purchaseCost;

  /// Dejanski ROI v odstotkih: ((Prihodki - Nabavni strošek) / Nabavni strošek) * 100
  double get roiPercentage {
    if (purchaseCost <= 0) return 0;
    return ((totalRevenueGenerated - purchaseCost) / purchaseCost) * 100;
  }

  /// Odstotek povrnjene investicije (Break-Even = 100%)
  double get costRecoveryPercentage {
    if (purchaseCost <= 0) return 100;
    return (totalRevenueGenerated / purchaseCost) * 100;
  }

  Item copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    double? dailyRate,
    double? purchaseCost,
    int? totalStock,
    int? availableStock,
    IconData? icon,
    Map<String, String>? specs,
    int? totalRentalsCount,
    double? totalRevenueGenerated,
    bool? underMaintenance,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      dailyRate: dailyRate ?? this.dailyRate,
      purchaseCost: purchaseCost ?? this.purchaseCost,
      totalStock: totalStock ?? this.totalStock,
      availableStock: availableStock ?? this.availableStock,
      icon: icon ?? this.icon,
      specs: specs ?? this.specs,
      totalRentalsCount: totalRentalsCount ?? this.totalRentalsCount,
      totalRevenueGenerated:
          totalRevenueGenerated ?? this.totalRevenueGenerated,
      underMaintenance: underMaintenance ?? this.underMaintenance,
    );
  }
}