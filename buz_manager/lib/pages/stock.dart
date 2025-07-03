import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:buz_manager/models/stock_model.dart';
import 'package:buz_manager/screens/reusable_func.dart'; // For showAddStockDialog()

class StockPage extends StatefulWidget {
  final String businessName;
  const StockPage({super.key, required this.businessName});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  @override
  Widget build(BuildContext context) {
    final stockBox = Hive.box<StockItem>('stockBox');
    final stockItems = stockBox.values
        .where((s) => s.businessName == widget.businessName)
        .toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    return Scaffold(
      backgroundColor: Colors.blue.shade500,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade500,
        centerTitle: true,
        title: const Text("Stock Inventory", style: TextStyle(color: Colors.white)),
      ),
      body: stockItems.isEmpty
          ? const Center(
              child: Text("No stock items.", style: TextStyle(color: Colors.white)),
            )
          : ListView.builder(
              itemCount: stockItems.length,
              itemBuilder: (_, index) {
                final stock = stockItems[index];
                return ListTile(
                  leading: const Icon(Icons.inventory, color: Colors.white),
                  title: Text(stock.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text("Unit: ${stock.unit}", style: const TextStyle(color: Colors.white70)),
                  trailing: Text("${stock.quantity} ${stock.unit}", style: const TextStyle(color: Colors.white)),
                  onTap: () => _showStockOptions(stock),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          await showAddStockDialog(context, widget.businessName);
          setState(() {});
        },
        backgroundColor: Colors.white,
        tooltip: "Add Stock",
        child: const Icon(Icons.add, color: Colors.orange),
      ),
    );
  }



void _showStockOptions(StockItem stock) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit"),
            onTap: () async {
              Navigator.pop(context);
              await showEditStockDialog(context, stock);
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Delete"),
            onTap: () async {
              Navigator.pop(context);
              final deleted = await confirmDeleteStock(context, stock);
              if (deleted) setState(() {});
            },
          ),
        ],
      ),
    );
  }
}