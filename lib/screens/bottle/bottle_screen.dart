import 'dart:io'; // For File handling
import 'package:flutter/material.dart';
import 'package:start2/screens/bottle/details.dart';
import 'package:start2/services/bottle.dart'; // Assuming you have a service to handle bottle data
import 'package:start2/models/bottle.dart'; // Assuming you have a Bottle model class
import 'package:start2/screens/bottle/add_edit.dart'; // Your add/edit screen for bottles

class BottlesScreen extends StatefulWidget {
  const BottlesScreen({super.key});

  @override
  _BottlesScreenState createState() => _BottlesScreenState();
}

class _BottlesScreenState extends State<BottlesScreen> {
  final BottleService _bottleService = BottleService();
  late Future<List<Bottle>> _bottlesList;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _bottlesList = _bottleService.getBottles();
  }

  Future<void> _refreshList() async {
    setState(() {
      _bottlesList = _bottleService.getBottles().then((bottles) => bottles.where((b) => b.brand.toLowerCase().contains(_searchQuery.toLowerCase())).toList());
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
      toolbarHeight: 35, // Set to the height of the button
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: _buildElevatedButton(),
        ),
      ],
    );
  }

  ElevatedButton _buildElevatedButton() {
    return ElevatedButton(
      onPressed: _navigateToAddEdit,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        minimumSize: const Size(75, 35), // Button height
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
      MaterialPageRoute(builder: (context) => const AddEditBottleScreen()),
    ).then((result) {
      if (result == true) {
        _refreshList();
      }
    });
  }

  Widget _buildBody() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 15),
            child: const Text(
              'My Bottles',
              style: TextStyle(
                color: Color.fromRGBO(67, 5, 157, 1),
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search bottles by brand...',
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _refreshList();
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Bottle>>(
            future: _bottlesList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading bottles.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              } else {
                return RefreshIndicator(
                  onRefresh: _refreshList,
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final bottle = snapshot.data![index];
                      return _buildListItem(bottle, index);
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

  Widget _buildListItem(Bottle bottle, int index) {
    final image = _loadImage(bottle.image);

    return InkWell(
      onTap: () => _navigateToDetails(bottle, index),
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Container(
          width: 170,
          height: 220,
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
                bottle.brand,
                style: const TextStyle(
                  color: Color.fromRGBO(121, 121, 121, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _loadImage(String imagePath) {
    return File(imagePath).existsSync()
        ? FileImage(File(imagePath))
        : const AssetImage('assets/icons/default_ink_bottle.png');
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
                  'no bottles added!',
                  style: TextStyle(
                    color: Color.fromRGBO(94, 93, 102, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/icons/default_ink_bottle.png', // Default cartridge image
              ),
              const SizedBox(height: 10),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'ADD YOUR BOTTLE',
                  style: TextStyle(
                    color: Color.fromRGBO(100, 12, 227, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(Bottle bottle, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BottleDetailsScreen(bottle: bottle, index: index),
      ),
    ).then((_) => _refreshList());
  }
}
