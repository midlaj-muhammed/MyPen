import 'package:flutter/material.dart';
import 'package:start2/models/pen.dart';
import 'package:start2/models/bottle.dart';
import 'package:start2/models/cartridge.dart';
import 'package:start2/services/pen.dart';
import 'package:start2/services/bottle.dart';
import 'package:start2/services/cartridge.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final PenService _penService = PenService();
  final BottleService _bottleService = BottleService();
  final CartridgeService _cartridgeService = CartridgeService();

  Future<Map<String, dynamic>> _fetchAnalytics() async {
    final pens = await _penService.getPens();
    final bottles = await _bottleService.getBottles();
    final cartridges = await _cartridgeService.getCartridges();

    double totalValue = 0;
    Map<String, int> brandCount = {};

    for (var p in pens) {
      totalValue += p.price ?? 0;
      brandCount[p.brand] = (brandCount[p.brand] ?? 0) + 1;
    }
    for (var b in bottles) {
      totalValue += (b.price * b.quantity);
      brandCount[b.brand] = (brandCount[b.brand] ?? 0) + 1;
    }
    for (var c in cartridges) {
      totalValue += (c.price * c.quantity);
      brandCount[c.brand] = (brandCount[c.brand] ?? 0) + 1;
    }

    var sortedBrands = brandCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalPens': pens.length,
      'totalInks': bottles.length + cartridges.length,
      'totalValue': totalValue,
      'topBrands': sortedBrands.take(3).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 30, fontWeight: FontWeight.w500)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchAnalytics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No analytical data available.'));
          }
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatCard('Total Value', '\$${data['totalValue'].toStringAsFixed(2)}', Icons.attach_money, Theme.of(context).colorScheme.primary),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Pens', '${data['totalPens']}', Icons.edit, Colors.blueAccent)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Inks', '${data['totalInks']}', Icons.water_drop, Colors.teal)),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Top Brands', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: (data['topBrands'] as List).length,
                    itemBuilder: (context, index) {
                      final brand = (data['topBrands'] as List)[index];
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Text('${index + 1}')),
                        title: Text(brand.key),
                        trailing: Text('${brand.value} items', style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
