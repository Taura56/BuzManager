import 'package:hive/hive.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 3)
class Sale extends HiveObject {
  @HiveField(0)
  String item;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String businessName;

  Sale({required this.item, required this.amount, required this.date, required this.businessName});
}
