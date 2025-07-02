import 'package:buz_manager/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:buz_manager/models/business_model.dart';


class BuzSelection extends StatefulWidget {
  const BuzSelection({super.key});

  @override
  State<BuzSelection> createState() => _BuzSelectionState();
}

class _BuzSelectionState extends State<BuzSelection> {
  late Box businessBox;
  @override
  void initState() {
    super.initState();
    businessBox= Hive.box<Business>('businessBox');
  }


  //Add a new Business
  void _addNewBusiness() {
  final TextEditingController textController = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Add New Business'),
      content: TextField(
        controller: textController,
        decoration: const InputDecoration(hintText: 'e.g., Kioski'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (textController.text.isNotEmpty) {
              final newBusiness = Business(
                name: textController.text.trim(),
                createdAt: DateTime.now(),
              );
              businessBox.add(newBusiness);
              setState(() {});
            }
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}


  //Select A Business
   void _selectBusiness(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HomePage(businessName: name)),
    );
  }



  @override
  Widget build(BuildContext context) {
    final businessList = businessBox.values.toList().cast<Business>();
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        centerTitle: true, title: Text(
          'Select Business',
          style: TextStyle(
            color: const Color.fromRGBO(255, 255, 255, 1),
            fontSize: 25.0,
          ),),
      backgroundColor: Colors.blue.shade700,
      ),
      body:  businessList.isEmpty
          ? const Center(child: Text(
            "No businesses found.\nTap + to add.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),))
      :ListView.builder(
        itemCount: businessList.length,
        itemBuilder: (_, index) {
          final biz = businessList[index];
          return ListTile(
            leading: const Icon(Icons.store, color: Colors.white, size: 40),
            title: Text(
              biz.name,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            onTap: () => _selectBusiness(biz.name),
          );
        },
      ),

        floatingActionButton: FloatingActionButton(
        onPressed: _addNewBusiness,
        child: const Icon(Icons.add),
    ),
    );

  }
}