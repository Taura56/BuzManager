import 'package:hive/hive.dart';

part 'stock_model.g.dart';

@HiveType(typeId: 2)
class StockItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  String unit; // e.g., pcs, kg

  @HiveField(3)
  String businessName;

  @HiveField(4)
  DateTime dateAdded;



  StockItem({required this.name, required this.quantity, required this.unit, required this.businessName, required this.dateAdded});
}
