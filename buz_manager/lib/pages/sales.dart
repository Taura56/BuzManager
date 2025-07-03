import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:buz_manager/models/sale_model.dart';
import 'package:buz_manager/screens/reusable_func.dart'; // For showAddSaleDialog()

class SalesPage extends StatefulWidget {
  final String businessName;
  const SalesPage({super.key, required this.businessName});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  @override
  Widget build(BuildContext context) {
    final salesBox = Hive.box<Sale>('salesBox');
    final sales = salesBox.values
        .where((sale) => sale.businessName == widget.businessName)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: Colors.blue.shade500,
      appBar: AppBar(title: const Text("Sales History",style: TextStyle(color: Colors.white,fontSize: 20.0)),
      backgroundColor: Colors.blue.shade500,
      centerTitle: true,),
      body: sales.isEmpty
          ? const Center(child: Text("No sales recorded."))
          : ListView.builder(
              itemCount: sales.length,
              itemBuilder: (_, index) {
                final sale = sales[index];
                return ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Colors.white),
                  title: Text(sale.item),
                  subtitle: Text(DateFormat('yyyy-MM-dd – hh:mm a').format(sale.date)),
                  trailing: Text("Ksh ${sale.amount.toStringAsFixed(2)}"),
                  onTap: () => _showSaleOptions(sale),
                );
              },
            ),

      // ✅ Add Floating Button to Add Sale
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          await showAddSaleDialog(context, widget.businessName);
          setState(() {}); // refresh the page after saving
        },
        backgroundColor: Colors.white,
        tooltip: "Add Sale",
        child: const Icon(Icons.add, color: Colors.blue,),
      ),
    );
  }
 void _showSaleOptions(Sale sale) {
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
              await showEditSaleDialog(context, sale);
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Delete"),
            onTap: () async {
              Navigator.pop(context);
              final deleted = await confirmDeleteSale(context, sale);
              if (deleted) setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

