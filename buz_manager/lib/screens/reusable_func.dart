import 'package:buz_manager/models/business_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:buz_manager/models/sale_model.dart';
import 'package:buz_manager/models/expense_model.dart';
import 'package:buz_manager/models/stock_model.dart';


Future<void> showAddSaleDialog(BuildContext context, String businessName) async {
  final saleBox = Hive.box<Sale>('salesBox');
  final stockBox = Hive.box<StockItem>('stockBox');

  List<StockItem> availableStock = stockBox.values
      .where((s) => s.businessName == businessName && s.quantity > 0)
      .toList();

  if (availableStock.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No stock available to sell")),
    );
    return;
  }

  StockItem? selectedItem = availableStock.first;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Add Sale"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<StockItem>(
            value: selectedItem,
            isExpanded: true,
            items: availableStock.map((stock) {
              return DropdownMenuItem(
                value: stock,
                child: Text(stock.name),
              );
            }).toList(),
            onChanged: (value) {
              selectedItem = value;
            },
            decoration: const InputDecoration(labelText: "Item to Sell"),
          ),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Quantity"),
          ),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Amount (Ksh)"),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text("Save"),
          onPressed: () {
            final int qty = int.tryParse(quantityController.text.trim()) ?? 0;
            final double amt = double.tryParse(amountController.text.trim()) ?? 0;

            if (selectedItem != null && qty > 0 && amt > 0 && qty <= selectedItem!.quantity) {
              // Save sale
              final sale = Sale(
                item: selectedItem!.name,
                amount: amt,
                date: DateTime.now(),
                businessName: businessName,
              );
              saleBox.add(sale);

              // Subtract stock
              selectedItem!.quantity -= qty;
              selectedItem!.save();

              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Invalid input or insufficient stock")),
              );
            }
          },
        ),
      ],
    ),
  );
}






Future<void> showAddExpenseDialog(BuildContext context, String businessName) {
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Add Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: reasonController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: "Amount (Ksh)"),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final reason = reasonController.text.trim();
            final amount = double.tryParse(amountController.text) ?? 0;
            if (reason.isNotEmpty && amount > 0) {
              final expense = Expense(
                reason: reason,
                amount: amount,
                date: DateTime.now(),
                businessName: businessName,
              );
              Hive.box<Expense>('expensesBox').add(expense);
              Navigator.pop(context);
              
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}






Future<void> showAddStockDialog(BuildContext context, String businessName) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  String selectedUnit = 'pcs';

 return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Stock'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Item Name"),
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: "Quantity"),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButton<String>(
                    value: selectedUnit,
                    isExpanded: true,
                    items: ['pcs', 'kg', 'liters']
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedUnit = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final qty = int.tryParse(quantityController.text) ?? 0;
                  if (name.isNotEmpty && qty > 0) {
                    final stock = StockItem(
                      name: name,
                      quantity: qty,
                      unit: selectedUnit,
                      businessName: businessName,
                      dateAdded: DateTime.now(),
                    );
                    Hive.box<StockItem>('stockBox').add(stock);
                    Navigator.pop(context);

                  }
                },
                child: const Text('Save'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
  );
}


//Edit Stock function
Future<void> showEditStockDialog(BuildContext context, StockItem stock) async {
  final nameController = TextEditingController(text: stock.name);
  final quantityController = TextEditingController(text: stock.quantity.toString());
  String selectedUnit = stock.unit;

  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Edit Stock"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: "Item Name")),
          TextField(
            controller: quantityController,
            decoration: const InputDecoration(labelText: "Quantity"),
            keyboardType: TextInputType.number,
          ),
          DropdownButton<String>(
            value: selectedUnit,
            isExpanded: true,
            items: ['pcs', 'kg', 'liters'].map((unit) {
              return DropdownMenuItem(value: unit, child: Text(unit));
            }).toList(),
            onChanged: (value) {
              if (value != null) selectedUnit = value;
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            stock.name = nameController.text.trim();
            stock.quantity = int.tryParse(quantityController.text.trim()) ?? stock.quantity;
            stock.unit = selectedUnit;
            stock.save();
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}

//Delete Stock function
Future<bool> confirmDeleteStock(BuildContext context, StockItem stock) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Delete Stock"),
          content: Text("Are you sure you want to delete '${stock.name}'?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                stock.delete();
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        ),
      ) ??
      false;
}


//Edit Sale Function
Future<void> showEditSaleDialog(BuildContext context, Sale sale) async {
  final itemController = TextEditingController(text: sale.item);
  final amountController = TextEditingController(text: sale.amount.toString());

  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Edit Sale"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: itemController, decoration: const InputDecoration(labelText: "Item")),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: "Amount"),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            sale.item = itemController.text.trim();
            sale.amount = double.tryParse(amountController.text) ?? sale.amount;
            sale.save();
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}


//Delete Sale Function
Future<bool> confirmDeleteSale(BuildContext context, Sale sale) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Delete Sale"),
          content: Text("Are you sure you want to delete '${sale.item}'?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                sale.delete();
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        ),
      ) ??
      false;
}



//Edit Exxpense Function
Future<void> showEditExpenseDialog(BuildContext context, Expense expense) async {
  final reasonController = TextEditingController(text: expense.reason);
  final amountController = TextEditingController(text: expense.amount.toString());

  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Edit Expense"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: reasonController, decoration: const InputDecoration(labelText: "Reason")),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: "Amount"),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            expense.reason = reasonController.text.trim();
            expense.amount = double.tryParse(amountController.text) ?? expense.amount;
            expense.save();
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}


//Delete Expense Function
Future<bool> confirmDeleteExpense(BuildContext context, Expense expense) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Delete Expense"),
          content: Text("Are you sure you want to delete '${expense.reason}'?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                expense.delete();
                Navigator.pop(context, true);
              },             
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        ),
      ) ??
           false;
}


//Edit Bussiness Function
Future<void> showEditBusinessDialog(BuildContext context, Business business) async {
  final TextEditingController controller = TextEditingController(text: business.name);

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Edit Business Name'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "Enter new name"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final newName = controller.text.trim();
            if (newName.isNotEmpty && newName != business.name) {
              final oldName = business.name;

              // Update the business name
              business.name = newName;
              business.save();

              // Update all related sales, expenses, and stock items
              final salesBox = Hive.box<Sale>('salesBox');
              final expensesBox = Hive.box<Expense>('expensesBox');
              final stockBox = Hive.box<StockItem>('stockBox');

              for (var sale in salesBox.values) {
                if (sale.businessName == oldName) {
                  sale.businessName = newName;
                  sale.save();
                }
              }

              for (var expense in expensesBox.values) {
                if (expense.businessName == oldName) {
                  expense.businessName = newName;
                  expense.save();
                }
              }

              for (var stock in stockBox.values) {
                if (stock.businessName == oldName) {
                  stock.businessName = newName;
                  stock.save();
                }
              }
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}



//Delete Business Function
Future<bool> confirmDeleteBusiness(BuildContext context, Business business) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Delete Business"),
          content: Text("Are you sure you want to delete '${business.name}'?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                business.delete();
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        ),
      ) ??
      false;
}
