import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:start2/add_session/add_session.dart';
import 'package:start2/connect_ink/select_ink_screen.dart';
import 'package:start2/models/bottle.dart';
import 'package:start2/models/cartridge.dart';
import 'package:start2/models/pen.dart';
import 'package:start2/screens/pen/add_edit.dart';
import 'package:start2/services/pen.dart';
import 'package:start2/services/bottle.dart';
import 'package:start2/services/cartridge.dart';

class PenDetailsScreen extends StatefulWidget {
  final Pen pen;
  final int index;
  final Bottle? bottle;

  const PenDetailsScreen(
      {super.key, required this.pen, required this.index, this.bottle});

  @override
  _PenDetailsScreenState createState() => _PenDetailsScreenState();
}

class _PenDetailsScreenState extends State<PenDetailsScreen> {
  final PenService _penService = PenService();
  final BottleService _bottleService = BottleService();
  final CartridgeService _cartridgeService = CartridgeService();
  late Future<Pen> _penFuture;

  @override
  void initState() {
    super.initState();
    _penFuture = _fetchPenDetails();
  }

  Future<Pen> _fetchPenDetails() async {
    final pens = await _penService.getPens();
    return pens[widget.index]; // Fetch the latest pen after any changes
  }

  void _refreshScreen() {
    setState(() {
      _penFuture = _fetchPenDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<Pen>(
              future: _penFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return const Center(
                      child: Text('Error loading pen details.'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('Pen not found.'));
                } else {
                  final pen = snapshot.data!;
                  return _buildPenDetails(pen);
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Ensure spacing between and at ends
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 15, right: 7.5, bottom: 20), // Left margin
                    child: _buildEditButton(),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 7.5, right: 15, bottom: 20), // Right margin
                    child: _buildDeleteButton(),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

// AppBar builder function
  AppBar _buildAppBar() {
    return AppBar();
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: 170,
      height: 35,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditPenScreen(
                pen: widget.pen,
                index: widget.index,
              ),
            ),
          ).then((_) => _refreshScreen()); // Refresh the screen after edit
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              const Color.fromRGBO(234, 232, 254, 1), // Background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'EDIT PEN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: 170,
      height: 35,
      child: ElevatedButton(
        onPressed: () async {
          await _penService.deletePen(widget.index);
          Navigator.pop(context); // Go back to the previous screen
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              const Color.fromRGBO(234, 232, 254, 1), // Background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'DELETE PEN',
          style: TextStyle(
              color:
                  Color.fromRGBO(214, 46, 102, 1), // Button color fontSize: 12,
              fontWeight: FontWeight.w500,
              fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildPenDetails(Pen pen) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  pen.brand,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(67, 5, 157, 1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  pen.model ?? 'Unknown Model',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(67, 5, 157, 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          _buildPenImage(pen),
          const SizedBox(height: 0),
          _buildAvailableVariants(pen),
          const SizedBox(height: 5),
          // Pass the current pen here
          Container(
            width: 345,
            height: 35,
            margin: const EdgeInsets.only(
              left: 15,
              right: 15,
            ), // Set consistent margin
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(
                    67, 5, 157, 1), // Button background color
                fixedSize: const Size(345, 35), // Set button size
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Set border radius to 10
                ),
              ),
              onPressed: () {
                navigateToAddSessionScreen(
                    context, widget.index, _refreshScreen);
              },
              child: const Text(
                'Add Session',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 12, // Font size
                  fontWeight: FontWeight.w500, // Font weight
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(left: 15.0),
            child: const Text(
              'Pen details',
              style: TextStyle(
                color: Color.fromRGBO(
                  94,
                  93,
                  102,
                  1,
                ),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 10),

          _buildPenInfo(pen),
          const SizedBox(height: 10),

          _buildInkConnectionButtons(pen),
          const SizedBox(height: 10),

          _buildConnectedInk(pen),
          const SizedBox(height: 10),
          _buildMaintenanceSection(pen),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSection(Pen pen) {
    bool needsCleaning = false;
    if (pen.inkId != null && pen.lastCleaned != null) {
      final daysSinceCleaned = DateTime.now().difference(pen.lastCleaned!).inDays;
      if (daysSinceCleaned > 30) {
        needsCleaning = true;
      }
    } else if (pen.inkId != null && pen.lastCleaned == null) {
      needsCleaning = true; // Never cleaned but inked
    }

    return Container(
      margin: const EdgeInsets.only(left: 15.0, right: 15.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: needsCleaning ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: needsCleaning ? Colors.red : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cleaning_services, color: needsCleaning ? Colors.red : Colors.blueGrey),
              const SizedBox(width: 10),
              Text('Maintenance Status', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (needsCleaning) ...[
                const Spacer(),
                const Icon(Icons.warning, color: Colors.red),
              ]
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pen.lastCleaned != null
                ? 'Last Cleaned: ${DateFormat('yyyy-MM-dd').format(pen.lastCleaned!)}'
                : 'Never cleaned',
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                pen.lastCleaned = DateTime.now();
                await pen.save();
                _refreshScreen();
              },
              child: const Text('Log Cleaning Today'),
            )
          )
        ],
      )
    );
  }

  Widget _buildAvailableVariants(Pen currentPen) {
    return FutureBuilder<List<Pen>>(
      future: _penService.getPens(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading variants.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No variants available.'));
        } else {
          final variants = snapshot.data!.where((pen) =>
              pen.brand == currentPen.brand &&
              pen.model == currentPen.model &&
              pen != currentPen); // Exclude the current pen

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
                            builder: (context) => const AddEditPenScreen(),
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
              ...variants.map(
                  (pen) => _buildVariantItem(pen, snapshot.data!.indexOf(pen))),
            ],
          );
        }
      },
    );
  }

  Widget _buildVariantItem(Pen pen, int index) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PenDetailsScreen(
              pen: pen,
              index: index,
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
                child: pen.image.isNotEmpty && File(pen.image).existsSync()
                    ? Image.file(
                        File(pen.image),
                        width: 50,
                        height: 50,
                        fit: BoxFit.fitWidth,
                      )
                    : const Placeholder(fallbackHeight: 50, fallbackWidth: 50),
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
  }

  Widget buildVariantList(List<Pen> pens) {
    return SizedBox(
      height: 100, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Horizontal scrolling
        itemCount: pens.length,
        itemBuilder: (context, index) {
          return _buildVariantItem(pens[index], index);
        },
      ),
    );
  }

  Widget _buildPenImage(Pen pen, {double width = 345, double height = 170}) {
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
                child: pen.image.isNotEmpty && File(pen.image).existsSync()
                    ? Image.file(
                        File(pen.image),
                        width: width,
                        height: height,
                        fit: BoxFit.fitWidth,
                      )
                    : Image.asset(
                        'assets/icons/default_pen.png',
                        width: width,
                        height: height,
                        fit: BoxFit.fitWidth,
                      ),
              ),
              const SizedBox(
                  height: 10), // Add spacing between the image and the text
              Text(
                pen.color ?? 'Unknown Color',
                style: const TextStyle(
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

  Widget _buildPenInfo(Pen pen) {
    return Container(
        margin: const EdgeInsets.only(left: 15.0),
        width: 345,
        height: 280,
        padding: const EdgeInsets.only(
            left: 15, top: 20), // Add left and top padding
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
                _buildLabeledDetail('Model', pen.model),
                _buildLabeledDetail('Type', pen.type),
              ],
            ),
            const SizedBox(height: 10), // Gap after each row
            Row(
              children: [
                _buildLabeledDetail('Material', pen.penMaterial),
                _buildLabeledDetail('Group', pen.penGroup),
              ],
            ),
            const SizedBox(height: 10), // Gap after each row
            Row(
              children: [
                _buildLabeledDetail('Nib Stroke', pen.nibStroke),
                _buildLabeledDetail('Nib Material', pen.nibMaterial),
              ],
            ),
            const SizedBox(height: 10), // Gap after each row
            Row(
              children: [
                _buildLabeledDetail('Nib Plating', pen.nibPlatting),
                _buildLabeledDetail(
                  'Purchase Date',
                  pen.purchaseDate != null
                      ? DateFormat('yyyy-MM-dd').format(pen.purchaseDate!)
                      : 'Not available',
                ),
              ],
            ),
            const SizedBox(height: 10), // Gap after each row
            Row(
              children: [
                _buildLabeledDetail(
                  'Price',
                  pen.price != null
                      ? '₹${pen.price!.toStringAsFixed(2)}'
                      : 'Not available',
                ),
                _buildLabeledDetail('Color', pen.color),
              ],
            ),
          ],
        ));
  }

  Widget _buildLabeledDetail(String label, String? value) {
    return SizedBox(
      width: 150, // Adjust width as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(151, 151, 151, 1), // Set label color
            ),
          ),
          const SizedBox(height: 0), // Optional spacing between label and value
          Text(
            value ?? 'Not available',
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromRGBO(0, 0, 0, 1), // Set label color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
            ),
          ),
          Flexible(
            child: Text(
              value ?? 'Not available',
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInkConnectionButtons(Pen pen) {
    bool isInkConnected = pen.inkId != null && pen.inkId!.isNotEmpty;

    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.04),
              child: Text(
                'Ink',
                style: TextStyle(
                  color: const Color.fromRGBO(94, 93, 102, 1),
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
              ),
            ),
            const Spacer(), // Add Spacer to push the button to the right
            Padding(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width *
                      0.04), // Add right padding
              child: TextButton(
                onPressed: () async {
                  await _handleConnectInk(pen);
                },
                child: Text(
                  isInkConnected ? 'CHANGE INK' : 'Connect Ink',
                  style: TextStyle(
                    color: const Color.fromRGBO(
                        67, 5, 157, 1), // Set text color to match the theme
                    fontSize: MediaQuery.of(context).size.width *
                        0.03, // Adjust font size as needed
                    fontWeight: FontWeight.w500, // Adjust font weight as needed
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  void navigateToAddSessionScreen(
      BuildContext context, int penIndex, Function refreshScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSessionScreen(penIndex: penIndex),
      ),
    ).then((_) => refreshScreen()); // Refresh the screen after adding a session
  }

  // Handle ink connection logic
  Future<void> _handleConnectInk(Pen pen) async {
    final bottles = await _bottleService.getBottles();
    final cartridges = await _cartridgeService.getCartridges();
    if (bottles.isEmpty && cartridges.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No inks added')),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectInkScreen(
            pen: pen,
            bottles: bottles,
            cartridges: cartridges,
            penIndex: widget.index,
            onInkChanged:
                _refreshScreen, // Refresh the screen after ink selection
          ),
        ),
      ).then((_) => _refreshScreen()); // Refresh after ink selection
    }
  }

  // Sessions display
  Widget _buildSessions(Pen pen) {
    if (pen.sessions.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pen.sessions.length,
      itemBuilder: (context, index) {
        return Text(
          'Session: ${DateFormat('yyyy-MM-dd').format(pen.sessions[index])}',
          style: const TextStyle(fontSize: 18),
        );
      },
    );
  }

  // Connected ink display
  Widget _buildConnectedInk(Pen pen) {
    if (pen.inkId == null) {
      return const Text('No ink connected');
    }

    final inkIdParts = pen.inkId!.split('-');
    if (inkIdParts.length < 2 || inkIdParts[1].isEmpty) {
      return const Text('Invalid ink ID format.');
    }

    final inkId = inkIdParts[1];
    final inkFuture = pen.inkId!.contains('bottle')
        ? _bottleService.getBottleById(inkId)
        : _cartridgeService.getCartridgeById(inkId);

    return FutureBuilder<Object?>(
      future: inkFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return const Text('Error loading ink details');
        } else if (!snapshot.hasData) {
          return const Text('Ink not found');
        } else {
          final ink = snapshot.data;
          if (ink is Bottle) {
            return _buildInkDisplay(ink.brand, 'Bottle');
          } else if (ink is Cartridge) {
            return _buildInkDisplay(ink.brand, 'Cartridge');
          } else {
            return const Text('Invalid ink type.');
          }
        }
      },
    );
  }

  Widget _buildInkDisplay(String brand, String type) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.1,
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        bottom: MediaQuery.of(context).size.height * 0.01,
      ), // Add padding if necessary
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            child: Row(
              children: [
                _buildLabeledDetails('Brand', brand),
                _buildLabeledDetails('Type', type),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledDetails(String label, String? value) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4, // Adjust width as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.03,
              fontWeight: FontWeight.bold,
              color: const Color.fromRGBO(151, 151, 151, 1), // Set label color
            ),
          ),
          SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.01), // Optional spacing between label and value
          Text(
            value ?? 'Not available',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.03,
              color: Colors.black, // Set details color to black
            ),
          ),
        ],
      ),
    );
  }
}
