import 'package:buz_manager/models/expense_model.dart';
import 'package:buz_manager/models/sale_model.dart';
import 'package:buz_manager/models/stock_model.dart';
import 'package:buz_manager/pages/expenses.dart';
import 'package:buz_manager/pages/sales.dart';
import 'package:buz_manager/pages/setting.dart';
import 'package:buz_manager/pages/stock.dart';
import 'package:buz_manager/screens/reusable_func.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final String businessName;
  const HomePage({super.key, required this.businessName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) _loadData();
    });
  }

  List<Widget> _pages() => [
        _buildDashboard(),
        SalesPage(businessName: widget.businessName),
        ExpensesPage(businessName: widget.businessName),
        StockPage(businessName: widget.businessName),
        SettingPage(businessName: widget.businessName)
      ];

double income = 0.0;
double expense = 0.0;

@override
void initState() {
  super.initState();
  _loadData(); 
}

void _loadData() {
  final salesBox = Hive.box<Sale>('salesBox');
  final expensesBox = Hive.box<Expense>('expensesBox');

  final sales = salesBox.values.where((s) => s.businessName == widget.businessName);
  final expenses = expensesBox.values.where((e) => e.businessName == widget.businessName);

  setState(() {
    income = sales.fold(0.0, (sum, item) => sum + item.amount);
    expense = expenses.fold(0.0, (sum, item) => sum + item.amount);
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade500,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        title: Text(
          '${widget.businessName} Dashboard',
          style: const TextStyle(color: Colors.white, fontSize: 25.0),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue.shade700,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Sales'),
          BottomNavigationBarItem(icon: Icon(Icons.money_off), label: 'Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final saleBox = Hive.box<Sale>('salesBox');
    final recentSales = saleBox.values
    .where((s) => s.businessName == widget.businessName)
    .toList()
    ..sort((a, b) => b.date.compareTo(a.date));



    final stockBox = Hive.box<StockItem>('stockBox');
    final inventory = stockBox.values
    .where((item) => item.businessName == widget.businessName)
    .toList();

    double balance = income - expense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Todays Income', income, Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _buildSummaryCard('Todays Expenses', expense, Colors.red)),
              const SizedBox(width: 10),
              Expanded(child: _buildSummaryCard('Balance', balance, Colors.blue.shade700)),
            ],
          ),

          const SizedBox(height: 30),
          const Text("Preview", style: TextStyle(color: Colors.white, fontSize: 20.0)),
          const SizedBox(height: 10),

          // Preview section (Inventory + Sell History)
          SizedBox(
            height: 170,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inventory
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Stock", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                      const SizedBox(height: 10),
                      ...inventory.take(2).map((item) => ListTile(
                        leading: const Icon(Icons.inventory, color: Colors.white),
                        title: Text(item.name, style: const TextStyle(color: Colors.white)),
                        trailing: Text("${item.quantity} ${item.unit}", style: const TextStyle(color: Colors.white)),
                        dense: true,
                      )),
                      if (inventory.length > 2)
                        const Text("...and more", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),


                VerticalDivider(width: 16, thickness: 1, color: Colors.white54),

                // Sell History
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Sell History", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                      const SizedBox(height: 10),
                      ...recentSales.take(2).map((sale) => ListTile(
                        title: Text(sale.item, style: const TextStyle(color: Colors.white)),
                        subtitle: Text("Ksh ${sale.amount.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white70)),
                        trailing: Text(_formatDateLabel(sale.date), style: const TextStyle(color: Colors.white70)),
                        dense: true,
                      )),
                      if (recentSales.length > 2)
                        const Text("...and more", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Text("Quick Actions", style: TextStyle(color: Colors.white, fontSize: 20.0)),
          const SizedBox(height: 10),

          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: _quickActionBtn(Icons.add_shopping_cart, "Add Sale", () async {
                 await showAddSaleDialog(context, widget.businessName);
                  _loadData();
                }),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: _quickActionBtn(Icons.remove_circle, "Add Expense", () async {
                 await showAddExpenseDialog(context, widget.businessName);
                  _loadData();
                }),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: _quickActionBtn(Icons.inventory, "Add Stock", () async {
                 await showAddStockDialog(context, widget.businessName);
                  _loadData();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Ksh ${amount.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _quickActionBtn(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
      ),
    );
  }
}

String _formatDateLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final input = DateTime(date.year, date.month, date.day);

  if (input == today) return "Today";
  if (input == today.subtract(const Duration(days: 1))) return "Yesterday";
  return DateFormat('MMM dd').format(date);
}
