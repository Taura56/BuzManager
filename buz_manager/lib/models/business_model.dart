import 'package:hive/hive.dart';
part 'business_model.g.dart';

@HiveType(typeId: 0)
class Business extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime createdAt;

  Business({required this.name, required this.createdAt});
}
