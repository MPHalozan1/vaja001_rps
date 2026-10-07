import 'package:flutter/material.dart';

class ItemCatalogScreen extends StatelessWidget {
  const ItemCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Catalog')),
      body: const Center(child: Text('Item Catalog Screen')),
    );
  }
}
