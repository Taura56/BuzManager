import 'package:buz_manager/screens/splash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path;

//models
import 'models/business_model.dart';
import 'models/sale_model.dart';
import 'models/expense_model.dart';
import 'models/stock_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Hive.initFlutter();
  }
  else{
    final dir = await path.getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
  }
  // Register adapters
  Hive.registerAdapter(BusinessAdapter());
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(StockItemAdapter());

  // Open Boxes
  await Hive.openBox<Business>('businessBox');
  await Hive.openBox<Sale>('salesBox');
  await Hive.openBox<Expense>('expensesBox');
  await Hive.openBox<StockItem>('stockBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

