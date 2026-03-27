import 'package:flutter/material.dart';
import 'dart:io'; // For handling local image files
import 'package:start2/models/cartridge.dart'; // Assuming you have a Cartridge model
import 'package:start2/models/pen.dart'; // Assuming you have a Pen model
import 'package:start2/screens/cartridge/add_edit.dart'; // Assuming you have an AddEditCartridgeScreen
import 'package:start2/services/cartridge.dart'; // Your CartridgeService
import 'package:start2/services/pen.dart'; // Your PenService

class CartridgeDetailsScreen extends StatefulWidget {
  final Cartridge cartridge;
  final int index;

  const CartridgeDetailsScreen(
      {super.key, required this.cartridge, required this.index});

  @override
  _CartridgeDetailsScreenState createState() => _CartridgeDetailsScreenState();
}

class _CartridgeDetailsScreenState extends State<CartridgeDetailsScreen> {
  final CartridgeService _cartridgeService = CartridgeService();
  final PenService _penService = PenService();
  late Future<Cartridge> _cartridgeFuture;
  late Future<List<Cartridge>> _variantCartridgesFuture;

  @override
  void initState() {
    super.initState();
    _cartridgeFuture = _fetchCartridgeDetails();
    _variantCartridgesFuture = _getVariantCartridges(widget.cartridge.brand);
  }

  Future<Cartridge> _fetchCartridgeDetails() async {
    final cartridges = await _cartridgeService.getCartridges();
    return cartridges[widget.index];
  }

  Future<List<Pen>> _getPensAssociatedWithCartridge(
      List<String>? penIds) async {
    if (penIds == null || penIds.isEmpty) return [];
    final allPens = await _penService.getPens();
    return allPens.where((pen) => penIds.contains(pen.key.toString())).toList();
  }

  Future<List<Cartridge>> _getVariantCartridges(String brand) async {
    final allCartridges = await _cartridgeService.getCartridges();
    return allCartridges
        .where((cartridge) =>
            cartridge.brand == brand && cartridge != widget.cartridge)
        .toList();
  }

  void _refreshScreen() {
    setState(() {
      _cartridgeFuture = _fetchCartridgeDetails();
      _variantCartridgesFuture = _getVariantCartridges(widget.cartridge.brand);
    });
  }

  Widget _buildAvailableVariants(Cartridge currentCartridge) {
    return FutureBuilder<List<Cartridge>>(
      future: _variantCartridgesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading variants.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No variants available.'));
        } else {
          final variants = snapshot.data!.where((cartridge) =>
              cartridge.brand == currentCartridge.brand &&
              cartridge != currentCartridge);

          if (variants.isEmpty) {
            return const Center(child: Text('No variants available.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Available Variants',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(94, 93, 102, 1),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(right: 10.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AddEditCartridgeScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'ADD VARIANT',
                        style: TextStyle(
                          color: Color.fromRGBO(67, 5, 157, 1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              buildVariantList(variants.toList()),
            ],
          );
        }
      },
    );
  }

  Widget buildVariantList(List<Cartridge> cartridges) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cartridges.length,
        itemBuilder: (context, index) {
          return _buildVariantItem(cartridges[index], index);
        },
      ),
    );
  }

  Widget _buildVariantItem(Cartridge cartridge, int index) {
    return InkWell(
      onTap: () async {
        final cartridges = await _cartridgeService.getCartridges();
        final cartridgeIndex = cartridges.indexOf(cartridge);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CartridgeDetailsScreen(
              cartridge: cartridge,
              index: cartridgeIndex,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Container(
          width: 170,
          height: 80,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          padding: const EdgeInsets.only(left: 15),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
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
            border: Border.all(
              color: const Color.fromRGBO(67, 5, 157, 1),
              width: 1.0,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                height: 50,
                child: cartridge.image.isNotEmpty &&
                        File(cartridge.image).existsSync()
                    ? Image.file(
                        File(cartridge.image),
                        width: 50,
                        height: 50,
                        fit: BoxFit.fitWidth,
                      )
                    : const Placeholder(fallbackHeight: 50, fallbackWidth: 50),
              ),
              Text(
                cartridge.inkColor ?? 'Unknown Color',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(0, 0, 0, 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildCartridgeDetails(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.cartridge.brand),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditCartridgeScreen(
                  cartridge: widget.cartridge,
                  index: widget.index,
                ),
              ),
            ).then((_) => _refreshScreen());
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await _cartridgeService.deleteCartridge(widget.index);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildCartridgeDetails() {
    return FutureBuilder<Cartridge>(
      future: _cartridgeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading cartridge details.'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Cartridge not found.'));
        } else {
          final cartridge = snapshot.data!;
          return _buildCartridgeUI(cartridge);
        }
      },
    );
  }

  Widget _buildBottleImage(String imagePath,
      {double width = 345, double height = 170}) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Container(
          width: width,
          height: 180, // Adjusted height to accommodate the additional content
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          padding: const EdgeInsets.only(left: 15),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(15), // Border radius set to 15
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
          clipBehavior: Clip.hardEdge, // Ensure corners are clipped properly
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 315,
                height: 120,
                child: imagePath.isNotEmpty && File(imagePath).existsSync()
                    ? Image.file(
                        File(imagePath),
                        width: width,
                        height: height,
                        fit: BoxFit.fitWidth,
                      )
                    : Image.asset(
                        'assets/icons/default_bottle.png',
                        width: width,
                        height: height,
                        fit: BoxFit.fitWidth,
                      ),
              ),
              const SizedBox(
                  height: 10), // Add spacing between the image and the text
              const Text(
                'Cartridge',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(0, 0, 0, 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartridgeUI(Cartridge cartridge) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBottleImage(cartridge.image),
          const SizedBox(height: 10),
          Text(cartridge.brand, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 10),
          _buildInkDetails(cartridge),
          const SizedBox(height: 20),
          const Text('Pens Filled with This Ink:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _buildPensList(cartridge),
          const SizedBox(height: 20),
          _buildAvailableVariants(cartridge),
          const SizedBox(height: 20),
        ], 
      ),
    );
  }

  Widget _buildInkDetails(Cartridge cartridge) {
    return Container(
      margin: const EdgeInsets.only(left: 0.0),
      width: 345,
      height: 280,
      padding:
          const EdgeInsets.only(left: 15, top: 20), // Add left and top padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildLabeledDetail('Ink Name', cartridge.inkName),
              _buildLabeledDetail('Ink Color', cartridge.inkColor),
            ],
          ),
          const SizedBox(height: 10), // Gap after each row
          Row(
            children: [
              _buildLabeledDetail('Ink Group', cartridge.inkGroup),
              _buildLabeledDetail('Quantity', cartridge.quantity.toString()),
            ],
          ),
          const SizedBox(height: 10), // Gap after each row
          Row(
            children: [
              _buildLabeledDetail(
                'Price',
                '₹${cartridge.price.toStringAsFixed(2)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledDetail(String label, String detail) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            detail,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPensList(Cartridge cartridge) {
    return FutureBuilder<List<Pen>>(
      future: _getPensAssociatedWithCartridge(cartridge.penIds),
      builder: (context, penSnapshot) {
        if (penSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (penSnapshot.hasError ||
            !penSnapshot.hasData ||
            penSnapshot.data!.isEmpty) {
          return const Center(child: Text('No pens associated with this ink.'));
        } else {
          final pens = penSnapshot.data!;
          return Column(
            children: pens.map((pen) {
              return InkWell(
                onTap: () {
                  // Add navigation or action logic here
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Container(
                    width: 170,
                    height:
                        80, // Adjusted height to accommodate the additional content
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    padding: const EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius:
                          BorderRadius.circular(15), // Border radius set to 15
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 105, 105, 105)
                              .withOpacity(0.1),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: const Color.fromRGBO(
                            67, 5, 157, 1), // Outline color
                        width: 1.0,
                      ),
                    ),
                    clipBehavior:
                        Clip.hardEdge, // Ensure corners are clipped properly
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 50,
                          child: pen.image.isNotEmpty &&
                                  File(pen.image).existsSync()
                              ? Image.file(
                                  File(pen.image),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.fitWidth,
                                )
                              : const Placeholder(
                                  fallbackHeight: 50, fallbackWidth: 50),
                        ),
                        // Add spacing between the image and the text
                        Text(
                          pen.color ?? 'Unknown Color',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }
}
