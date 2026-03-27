import 'package:flutter/material.dart';
import 'package:start2/models/pen.dart';
import 'package:start2/models/bottle.dart';
import 'package:start2/models/cartridge.dart';
import 'package:start2/services/pen.dart';
import 'package:start2/services/bottle.dart';
import 'package:start2/services/cartridge.dart';

class SelectInkScreen extends StatefulWidget {
  final Pen pen;
  final List<Bottle> bottles;
  final List<Cartridge> cartridges;
  final int penIndex;
  final Function onInkChanged;

  const SelectInkScreen({
    super.key,
    required this.pen,
    required this.bottles,
    required this.cartridges,
    required this.penIndex,
    required this.onInkChanged,
  });

  @override
  _SelectInkScreenState createState() => _SelectInkScreenState();
}

class _SelectInkScreenState extends State<SelectInkScreen> {
  final PenService penService = PenService();
  final BottleService bottleService = BottleService();
  final CartridgeService cartridgeService = CartridgeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Ink for ${widget.pen.brand}'),
      ),
      body: ListView.builder(
        itemCount: widget.bottles.length + widget.cartridges.length,
        itemBuilder: (context, index) {
          if (index < widget.bottles.length) {
            final ink = widget.bottles[index];
            return ListTile(
              title: Text(ink.brand),
              subtitle: const Text('Bottle'),
              onTap: () async {
                await _handleInkSelection(ink, 'bottle', index);
                widget.onInkChanged();
                Navigator.pop(context, true);
              },
            );
          } else {
            final cartridgeIndex = index - widget.bottles.length;
            final ink = widget.cartridges[cartridgeIndex];
            return ListTile(
              title: Text(ink.brand),
              subtitle: const Text('Cartridge'),
              onTap: () async {
                await _handleInkSelection(ink, 'cartridge', cartridgeIndex);
                widget.onInkChanged();
                Navigator.pop(context, true);
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _handleInkSelection(
      dynamic ink, String inkType, int index) async {
    // Remove the pen's ID from the previously selected ink if any
    if (widget.pen.inkId != null) {
      await _removePenFromPreviousInk(widget.pen.inkId!);
    }

    // Assign the new ink to the pen
    widget.pen.inkId = '$inkType-${ink.key.toString()}';

    // Save the updated pen back to Hive to persist the ink change
    await penService.updatePen(widget.penIndex, widget.pen);
    await widget.pen.save(); // Ensure the pen is saved to Hive

    // Save pen ID to the selected ink
    ink.penIds = List<String>.from(ink.penIds ?? []); // Ensure it's a list
    if (!ink.penIds!.contains(widget.pen.key.toString())) {
      ink.penIds!.add(widget.pen.key.toString());
    }

    // **Important**: Persist the updated bottle/cartridge back to Hive
    if (inkType == 'bottle') {
      await bottleService.updateBottle(index, ink);
      await ink.save(); // Ensure it is saved back to Hive
    } else if (inkType == 'cartridge') {
      await cartridgeService.updateCartridge(index, ink);
      await ink.save(); // Ensure it is saved back to Hive
    }

    // Trigger UI update after ink is selected
    setState(() {});
  }

  Future<void> _removePenFromPreviousInk(String previousInkId) async {
    if (previousInkId.startsWith('bottle')) {
      final previousBottle =
          await bottleService.getBottleById(previousInkId.split('-')[1]);
      if (previousBottle != null) {
        // Safely remove the pen ID from the bottle's list of pen IDs
        previousBottle.penIds = List<String>.from(previousBottle.penIds ?? [])
          ..remove(widget.pen.key.toString());

        // **Important**: Persist the updated bottle back to Hive
        await bottleService.updateBottle(previousBottle.key!, previousBottle);
        await previousBottle.save(); // Ensure it is saved back to Hive
      }
    } else if (previousInkId.startsWith('cartridge')) {
      final previousCartridge =
          await cartridgeService.getCartridgeById(previousInkId.split('-')[1]);
      if (previousCartridge != null) {
        // Safely remove the pen ID from the cartridge's list of pen IDs
        previousCartridge.penIds =
            List<String>.from(previousCartridge.penIds ?? [])
              ..remove(widget.pen.key.toString());

        // **Important**: Persist the updated cartridge back to Hive
        await cartridgeService.updateCartridge(
            previousCartridge.key!, previousCartridge);
        await previousCartridge.save(); // Ensure it is saved back to Hive
      }
    }
  }
}
