import 'package:flutter/material.dart';
import 'package:start2/models/wishlist_item.dart';
import 'package:start2/services/wishlist.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  late Future<List<WishlistItem>> _itemsList;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _itemsList = _wishlistService.getItems();
    });
  }

  void _showAddItemDialog() {
    String name = '';
    String brand = '';
    double price = 0.0;
    String type = 'Pen';
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Add to Wishlist'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(decoration: const InputDecoration(labelText: 'Brand'), onChanged: (v) => brand = v),
                  TextField(decoration: const InputDecoration(labelText: 'Name'), onChanged: (v) => name = v),
                  TextField(decoration: const InputDecoration(labelText: 'Target Price'), keyboardType: TextInputType.number, onChanged: (v) => price = double.tryParse(v) ?? 0.0),
                  DropdownButton<String>(
                    value: type,
                    items: ['Pen', 'Bottle', 'Cartridge'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setLocalState(() => type = v!),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (brand.isNotEmpty && name.isNotEmpty) {
                      final item = WishlistItem(brand: brand, name: name, targetPrice: price, itemType: type);
                      await _wishlistService.addItem(item);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      _refreshList();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist', style: TextStyle(color: Color.fromRGBO(67, 5, 157, 1), fontSize: 30, fontWeight: FontWeight.w500)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
      ),
      body: FutureBuilder<List<WishlistItem>>(
        future: _itemsList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text('Your wishlist is empty!'));
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text('${item.brand} - ${item.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.itemType} | \$${item.targetPrice}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _wishlistService.deleteItem(index);
                      _refreshList();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
