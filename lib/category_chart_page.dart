import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CategoryChartPage extends StatefulWidget {
  const CategoryChartPage({Key? key}) : super(key: key);

  @override
  _CategoryChartPageState createState() => _CategoryChartPageState();
}

class _CategoryChartPageState extends State<CategoryChartPage> {
  late Stream<QuerySnapshot> _categoriesStream;
  late Stream<QuerySnapshot> _productsStream;

  @override
  void initState() {
    super.initState();
    _categoriesStream =
        FirebaseFirestore.instance.collection('categories').snapshots();
    _productsStream =
        FirebaseFirestore.instance.collection('products').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quantités des catégories'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucun produit trouvé.'));
          }

          // Calculate the quantities of each category
          Map<String, int> categoryQuantities = {};

          snapshot.data!.docs.forEach((product) {
            String category = product['category'];
            int quantity = product['quantity'];

            if (categoryQuantities.containsKey(category)) {
              categoryQuantities[category] =
                  categoryQuantities[category]! + quantity;
            } else {
              categoryQuantities[category] = quantity;
            }
          });

          // Convert the data to a format suitable for charts_flutter
          List<charts.Series<MapEntry<String, int>, String>> series = [
            charts.Series<MapEntry<String, int>, String>(
              id: 'Quantités',
              domainFn: (MapEntry<String, int> entry, _) => entry.key,
              measureFn: (MapEntry<String, int> entry, _) => entry.value,
              data: categoryQuantities.entries.toList(),
              labelAccessorFn: (MapEntry<String, int> entry, _) =>
                  '${entry.value}',
            )
          ];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: charts.BarChart(
              series,
              animate: true,
              barRendererDecorator: charts.BarLabelDecorator<String>(),
              domainAxis: charts.OrdinalAxisSpec(),
            ),
          );
        },
      ),
    );
  }
}
