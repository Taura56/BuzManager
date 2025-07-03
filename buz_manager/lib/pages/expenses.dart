import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:buz_manager/models/expense_model.dart';
import 'package:buz_manager/screens/reusable_func.dart'; // For showAddExpenseDialog()

class ExpensesPage extends StatefulWidget {
  final String businessName;
  const ExpensesPage({super.key, required this.businessName});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  Widget build(BuildContext context) {
    final expenseBox = Hive.box<Expense>('expensesBox');
    final expenses = expenseBox.values
        .where((e) => e.businessName == widget.businessName)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: Colors.blue.shade500,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade500,
        centerTitle: true,
        title: const Text("Expense History", style: TextStyle(color: Colors.white)),
      ),
      body: expenses.isEmpty
          ? const Center(
              child: Text("No expenses recorded.", style: TextStyle(color: Colors.white)),
            )
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (_, index) {
                final expense = expenses[index];
                return ListTile(
                  leading: const Icon(Icons.money_off, color: Colors.white),
                  title: Text(expense.reason, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd – hh:mm a').format(expense.date),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text("Ksh ${expense.amount.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.white)),
                      onTap: () => _showExpenseOptions(expense),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          await showAddExpenseDialog(context, widget.businessName);
          setState(() {});
        },
        backgroundColor: Colors.white,
        tooltip: "Add Expense",
        child: const Icon(Icons.add, color: Colors.red),
      ),
    );
  }

  void _showExpenseOptions(Expense expense) {
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
              await showEditExpenseDialog(context, expense);
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Delete"),
            onTap: () async {
              Navigator.pop(context);
              final deleted = await confirmDeleteExpense(context, expense);
              if (deleted) setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

