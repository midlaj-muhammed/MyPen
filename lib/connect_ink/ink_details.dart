import 'package:flutter/material.dart';
import 'package:start2/services/bottle.dart';
import 'package:start2/services/cartridge.dart';
import 'package:start2/services/pen.dart';
import 'package:start2/models/bottle.dart';
import 'package:start2/models/cartridge.dart';
import 'package:start2/models/pen.dart'; // Make sure to import Pen model

class InkDetails extends StatefulWidget {
  final String inkId;

  const InkDetails({super.key, required this.inkId});

  @override
  _InkDetailsState createState() => _InkDetailsState();
}

class _InkDetailsState extends State<InkDetails> {
  late Future<Object?> inkDetailsFuture;

  @override
  void initState() {
    super.initState();
    inkDetailsFuture = fetchInkDetails();
  }

  Future<void> refreshInkDetails() async {
    setState(() {
      inkDetailsFuture = fetchInkDetails();
    });
  }

  Future<Object?> fetchInkDetails() {
    final bottleService = BottleService();
    final cartridgeService = CartridgeService();

    if (widget.inkId.startsWith('bottle')) {
      return bottleService.getBottleById(widget.inkId);
    } else if (widget.inkId.startsWith('cartridge')) {
      return cartridgeService.getCartridgeById(widget.inkId);
    } else {
      return Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object?>(
      future: inkDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading ink details.'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No ink details available.'));
        } else {
          final ink = snapshot.data;
          if (ink is Bottle || ink is Cartridge) {
            final brand = ink is Bottle ? ink.brand : (ink as Cartridge).brand;
            final inkKey = ink is Bottle ? ink.key : (ink as Cartridge).key;

            return FutureBuilder<Pen?>(
              future: PenService().getPenByInkId(inkKey.toString()),
              builder: (context, penSnapshot) {
                if (penSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (penSnapshot.hasError) {
                  return const Center(
                      child: Text('Error loading pen details.'));
                } else if (!penSnapshot.hasData) {
                  return const Center(
                      child: Text('No pen associated with this ink.'));
                } else {
                  final pen = penSnapshot.data;

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ink Brand: $brand',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black)),
                        const SizedBox(height: 10),
                        if (pen != null) ...[
                          Text('Pen Brand: ${pen.brand}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 5),
                          pen.image != null
                              ? Image.network(
                                  pen.image,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                        Icons.image_not_supported);
                                  },
                                )
                              : const Icon(Icons.image_not_supported),
                        ],
                      ],
                    ),
                  );
                }
              },
            );
          } else {
            return const Center(child: Text('Invalid ink type.'));
          }
        }
      },
    );
  }
}
