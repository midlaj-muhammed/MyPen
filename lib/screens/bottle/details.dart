import 'package:flutter/material.dart';
import 'dart:io'; // For handling local image files
import 'package:start2/models/bottle.dart'; // Assuming you have a Bottle model
import 'package:start2/models/pen.dart';
import 'package:start2/screens/bottle/add_edit.dart'; // Assuming you have an AddEditBottleScreen
import 'package:start2/services/bottle.dart';
import 'package:start2/services/pen.dart'; // Your BottleService

class BottleDetailsScreen extends StatefulWidget {
  final Bottle bottle;
  final int index;

  const BottleDetailsScreen(
      {super.key, required this.bottle, required this.index});

  @override
  _BottleDetailsScreenState createState() => _BottleDetailsScreenState();
}

class _BottleDetailsScreenState extends State<BottleDetailsScreen> {
  final BottleService _bottleService = BottleService();
  final PenService _penService = PenService();
  late Future<Bottle> _bottleFuture;
  late Future<List<Pen>>
      _pensFuture; // To fetch all pens associated with the bottle
  late Future<List<Bottle>>
      _variantBottlesFuture; // To fetch all bottles with the same brand

  @override
  void initState() {
    super.initState();
    _bottleFuture = _fetchBottleDetails();
    _pensFuture = _getPensAssociatedWithBottle(
        widget.bottle.penIds); // Fetch associated pens
    _variantBottlesFuture = _getVariantBottles(
        widget.bottle.brand); // Fetch bottles with same brand
  }

  Future<Bottle> _fetchBottleDetails() async {
    final bottles = await _bottleService.getBottles();
    return bottles[widget.index];
  }

  Future<List<Pen>> _getPensAssociatedWithBottle(List<String>? penIds) async {
    if (penIds == null) return [];
    final allPens = await _penService.getPens();
    return allPens.where((pen) => penIds.contains(pen.key.toString())).toList();
  }

  Future<List<Bottle>> _getVariantBottles(String brand) async {
    final allBottles = await _bottleService.getBottles();
    return allBottles
        .where((bottle) => bottle.brand == brand && bottle != widget.bottle)
        .toList();
  }

  Widget _buildAvailableVariants(Bottle currentBottle) {
    return FutureBuilder<List<Bottle>>(
      future: _variantBottlesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading variants.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No variants available.'));
        } else {
          final variants = snapshot.data!.where((bottle) =>
              bottle.brand == currentBottle.brand &&
              bottle != currentBottle); // Exclude the current bottle

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
                        color: Color.fromRGBO(
                          94,
                          93,
                          102,
                          1,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(), // Add Spacer to push the button to the right
                  Container(
                    margin:
                        const EdgeInsets.only(right: 10.0), // Add right margin
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddEditBottleScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'ADD VARIANT',
                        style: TextStyle(
                          color: Color.fromRGBO(67, 5, 157,
                              1), // Set text color to match the theme
                          fontSize: 12, // Adjust font size as needed
                          fontWeight:
                              FontWeight.w500, // Adjust font weight as needed
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

  Widget buildVariantList(List<Bottle> bottles) {
    return SizedBox(
      height: 100, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Horizontal scrolling
        itemCount: bottles.length,
        itemBuilder: (context, index) {
          return _buildVariantItem(bottles[index], index);
        },
      ),
    );
  }

  Widget _buildVariantItem(Bottle bottle, int index) {
    return InkWell(
      onTap: () async {
        final bottles = await _bottleService.getBottles();
        final bottleIndex = bottles.indexOf(bottle);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottleDetailsScreen(
              bottle: bottle,
              index: bottleIndex,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Container(
          width: 170,
          height: 80, // Adjusted height to accommodate the additional content
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
            border: Border.all(
              color: const Color.fromRGBO(67, 5, 157, 1), // Outline color
              width: 1.0,
            ),
          ),
          clipBehavior: Clip.hardEdge, // Ensure corners are clipped properly
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                height: 50,
                child: bottle.image.isNotEmpty &&
                        File(bottle.image).existsSync()
                    ? Image.file(
                        File(bottle.image),
                        width: 50,
                        height: 50,
                        fit: BoxFit.fitWidth,
                      )
                    : const Placeholder(fallbackHeight: 50, fallbackWidth: 50),
              ),
              // Add spacing between the image and the text
              Text(
                bottle.inkColor ?? 'Unknown Color',
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

  void _refreshScreen() {
    setState(() {
      _bottleFuture = _fetchBottleDetails();
      _pensFuture = _getPensAssociatedWithBottle(widget.bottle.penIds);
      _variantBottlesFuture = _getVariantBottles(widget.bottle.brand);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.bottle.brand),
      actions: [
        _buildEditButton(context),
        _buildDeleteButton(context),
      ],
    );
  }

  IconButton _buildEditButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEditBottleScreen(
              bottle: widget.bottle,
              index: widget.index,
            ),
          ),
        ).then((_) => _refreshScreen());
      },
    );
  }

  IconButton _buildDeleteButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        await _bottleService.deleteBottle(widget.index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBody() {
    return FutureBuilder<Bottle>(
      future: _bottleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading bottle details.'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Bottle not found.'));
        } else {
          final bottle = snapshot.data!;
          return _buildBottleDetails(bottle);
        }
      },
    );
  }

  Widget _buildBottleDetails(Bottle bottle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBottleBrand(bottle.brand),
          const SizedBox(height: 10),
          _buildBottleImage(bottle.image),
          const SizedBox(height: 10),
          _buildAvailableVariants(bottle),
          const SizedBox(height: 20),
          _buildInkDetails(bottle),
          const SizedBox(height: 20),
          _buildPensWithInkSection(),
        ],
      ),
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
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
                'Bottle',
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

  Widget _buildBottleBrand(String brand) {
    return Text(brand, style: const TextStyle(fontSize: 24));
  }

  Widget _buildInkDetails(Bottle bottle) {
    return Container(
      margin: const EdgeInsets.only(left: 15.0),
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
              _buildLabeledDetail('Ink Name', bottle.inkName),
              _buildLabeledDetail('Ink Color', bottle.inkColor),
            ],
          ),
          const SizedBox(height: 10), // Gap after each row
          Row(
            children: [
              _buildLabeledDetail('Ink Color Name', bottle.inkColorName),
              _buildLabeledDetail('Ink Group', bottle.inkGroup),
            ],
          ),
          const SizedBox(height: 10), // Gap after each row
          Row(
            children: [
              _buildLabeledDetail('Quantity', bottle.quantity.toString()),
              _buildLabeledDetail(
                'Price',
                '₹${bottle.price.toStringAsFixed(2)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPensWithInkSection() {
    return FutureBuilder<List<Pen>>(
      future: _pensFuture,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Pens Filled with This Ink:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(), // Add Spacer to push the button to the right
                ],
              ),
              _buildPensList(pens),
            ],
          );
        }
      },
    );
  }

  Widget _buildPensList(List<Pen> pens) {
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
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
                  color: const Color.fromRGBO(67, 5, 157, 1), // Outline color
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
                    child: pen.image.isNotEmpty && File(pen.image).existsSync()
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
}
