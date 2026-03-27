import 'package:flutter/material.dart';
import 'dart:io'; // For handling local image files
import 'package:start2/models/cartridge.dart'; // Assuming you have a Cartridge model
import 'package:start2/screens/cartridge/details.dart';
import 'package:start2/services/cartridge.dart'; // Assuming you have a CartridgeService
import 'package:start2/screens/cartridge/add_edit.dart'; // Assuming you have an AddEditCartridgeScreen

class CartridgesScreen extends StatefulWidget {
  const CartridgesScreen({super.key});

  @override
  _CartridgesScreenState createState() => _CartridgesScreenState();
}

class _CartridgesScreenState extends State<CartridgesScreen> {
  final CartridgeService _cartridgeService =
      CartridgeService(); // Assuming you have a CartridgeService
  late Future<List<Cartridge>> _cartridgesList;

  @override
  void initState() {
    super.initState();
    _cartridgesList =
        _cartridgeService.getCartridges(); // Initialize cartridges list
  }

  Future<void> _refreshList() async {
    setState(() {
      _cartridgesList =
          _cartridgeService.getCartridges(); // Re-fetch cartridges after update
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 10), // Add consistent margin
          child: _buildElevatedButton(),
        )
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 15),
            child: const Text(
              'My Cartridges',
              style: TextStyle(
                color: Color.fromRGBO(67, 5, 157, 1), // Text color
                fontSize: 30, // Font size
                fontWeight: FontWeight.w500, // Font weight
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Cartridge>>(
            future: _cartridgesList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading cartridges.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              } else {
                return RefreshIndicator(
                  onRefresh: _refreshList,
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final cartridge = snapshot.data![index];
                      return _buildListItem(cartridge, index);
                    },
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(left: 15, top: 5, right: 15),
      alignment: Alignment.topLeft, // Align the container to the top left
      child: SizedBox(
        width: 160, // Set width explicitly
        height: 180, // Set height explicitly
        child: OutlinedButton(
          onPressed: _navigateToAddEdit,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
                Colors.white), // Set background color to white
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            side: MaterialStateProperty.all(
              const BorderSide(
                color: Color.fromRGBO(234, 232, 254, 1),
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'no cartridges added!',
                  style: TextStyle(
                    color: Color.fromRGBO(94, 93, 102, 1),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/icons/cartridge.png', // Default cartridge image
              ),
              const SizedBox(height: 10),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'ADD YOUR CARTRIDGE',
                  style: TextStyle(
                    color: Color.fromRGBO(100, 12, 227, 1),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(Cartridge cartridge, int index) {
    final image = _loadImage(cartridge.image);

    return InkWell(
      onTap: () => _navigateToDetails(cartridge, index), // Navigate on tap
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Container(
          width: 345,
          height: 200, // Adjusted height to match PensScreen
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          padding: const EdgeInsets.only(left: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color:
                    const Color.fromARGB(255, 105, 105, 105).withOpacity(0.1),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image(
                image: image,
                width: 315,
                height: 120,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 10),
              Text(
                cartridge.brand,
                style: const TextStyle(
                  color: Color.fromRGBO(121, 121, 121, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              // Row(
              //   children: [
              //     Text(
              //       cartridge.type ?? 'Unknown Type', // Handle null case
              //       style: const TextStyle(
              //         color: Color.fromARGB(255, 0, 0, 0),
              //         fontSize: 16,
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _loadImage(String imagePath) {
    return File(imagePath).existsSync()
        ? FileImage(File(imagePath))
        : const AssetImage('assets/placeholder.png');
  }

  void _navigateToDetails(Cartridge cartridge, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CartridgeDetailsScreen(cartridge: cartridge, index: index),
      ),
    ).then((_) => _refreshList());
  }

  ElevatedButton _buildElevatedButton() {
    return ElevatedButton(
      onPressed: _navigateToAddEdit,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        minimumSize: const Size(75, 35),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: const Text(
        'ADD NEW',
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  void _navigateToAddEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditCartridgeScreen()),
    ).then((result) {
      if (result == true) {
        _refreshList();
      }
    });
  }
}
