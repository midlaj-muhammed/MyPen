import 'package:flutter/material.dart';
import 'dart:io'; // For handling local image files
import 'package:image_picker/image_picker.dart'; // To pick images
import 'package:path_provider/path_provider.dart';
import 'package:start2/models/cartridge.dart'; // Assuming you have a Cartridge model
import 'package:start2/services/cartridge.dart'; // Assuming you have a CartridgeService
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // For color picker
import 'package:path/path.dart' as path;

class AddEditCartridgeScreen extends StatefulWidget {
  final Cartridge? cartridge;
  final int? index;

  const AddEditCartridgeScreen({super.key, this.cartridge, this.index});

  @override
  _AddEditCartridgeScreenState createState() => _AddEditCartridgeScreenState();
}

class _AddEditCartridgeScreenState extends State<AddEditCartridgeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _inkNameController = TextEditingController();
  final _inkColorNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  File? _imageFile;
  String? _selectedGroup;
  Color _selectedColor = Colors.black; // Default color
  final List<String> _inkGroups = ['Group A', 'Group B', 'Group C'];
  final CartridgeService _cartridgeService = CartridgeService();

  @override
  void initState() {
    super.initState();
    if (widget.cartridge != null) {
      _loadCartridgeData(widget.cartridge!);
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _inkNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _inkColorNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Get the directory to save the image
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImagePath = path.join(appDir.path, fileName);

      // Save the image to the permanent location
      final savedImage = await File(pickedFile.path).copy(savedImagePath);

      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  Future<void> _pickColor() async {
    Color pickedColor = _selectedColor;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Ink Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                pickedColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedColor = pickedColor;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  void _loadCartridgeData(Cartridge cartridge) {
    _brandController.text = cartridge.brand;
    _inkNameController.text = cartridge.inkName;
    _selectedColor = Color(int.parse(cartridge.inkColor, radix: 16));

    // Ensure selected group is valid
    if (_inkGroups.contains(cartridge.inkGroup)) {
      _selectedGroup = cartridge.inkGroup;
    } else {
      _selectedGroup = null; // Or set to a default group if you prefer
    }

    _quantityController.text = cartridge.quantity.toString();
    _priceController.text = cartridge.price.toString();
    _inkColorNameController.text = cartridge.inkColorName;
    _imageFile = File(cartridge.image);
  }

  void _saveCartridge() async {
    // Ensure _selectedGroup is not null
    _selectedGroup ??= _inkGroups.isNotEmpty ? _inkGroups[0] : 'Default Group';

    final cartridge = await _createCartridge(); // Await the cartridge creation
    if (widget.index == null) {
      await _cartridgeService.addCartridge(cartridge);
    } else {
      await _cartridgeService.updateCartridge(widget.index!, cartridge);
    }
    Navigator.pop(context, true);
  }

  Future<Cartridge> _createCartridge() async {
    Cartridge? existingCartridge;

    // Fetch the list of cartridges asynchronously
    final cartridges = await _cartridgeService.getCartridges();

    // Check if there is a cartridge at the specific index if editing
    if (widget.index != null && widget.index! < cartridges.length) {
      existingCartridge = cartridges[widget.index!];
    }

    // Ensure the inkId remains the same if not updated by the user
    final inkId = existingCartridge?.inkId ??
        'cartridge-${DateTime.now().millisecondsSinceEpoch}';

    return Cartridge(
      brand: _brandController.text.isNotEmpty
          ? _brandController.text
          : existingCartridge?.brand ?? 'Default Brand',
      image: _imageFile?.path ??
          existingCartridge?.image ??
          'default_image_path', // Provide a default image path if no image is selected
      penIds: [], // Initialize an empty list for penIds
      inkName: _inkNameController.text.isNotEmpty
          ? _inkNameController.text
          : existingCartridge?.inkName ?? 'Default Ink Name',
      inkColor: _selectedColor.value.toRadixString(16),
      inkGroup:
          _selectedGroup ?? existingCartridge?.inkGroup ?? 'Default Group',
      quantity: int.tryParse(_quantityController.text) ??
          existingCartridge?.quantity ??
          0, // Default to 0 if the input is not a valid number
      price: double.tryParse(_priceController.text) ??
          existingCartridge?.price ??
          0.0, // Default to 0.0 if the input is not a valid number
      inkColorName: _inkColorNameController.text.isNotEmpty
          ? _inkColorNameController.text
          : existingCartridge?.inkColorName ?? 'Default Ink Color Name',
    );
  }

  Widget _buildRow({
    required Widget leftChild,
    required Widget rightChild,
  }) {
    return Row(
      children: [
        Expanded(child: leftChild),
        const SizedBox(width: 10),
        Expanded(child: rightChild),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Container(
      width: 345,
      height: 190,
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 232, 254, 1)),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          _imageFile == null
              ? Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/default_pen.png',
                        width: 260,
                        height: 30,
                      ),
                    ],
                  ),
                )
              : Image.file(_imageFile!, width: 100, height: 100),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: TextButton(
              onPressed: _pickImage,
              child: Text(
                _imageFile == null ? 'Select Image' : 'Change Image',
                style: const TextStyle(
                    color: Color.fromRGBO(100, 12, 227, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
  }) {
    return SizedBox(
      width: 170,
      height: 80, // Adjusted height to accommodate the label and dropdown
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0,
                bottom: 2.0), // Adjusted padding for better alignment
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(94, 93, 102, 1), // Label text color
              ),
            ),
          ),
          const SizedBox(
            height: 2, // Space between label and dropdown
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                isDense:
                    true, // Reduces the default padding inside the dropdown
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 13.0), // Custom padding
                hintText: 'Select Ink Group',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey, // Hint text color
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(234, 232, 254, 1), // Border color
                    width: 1, // Border width
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(234, 232, 254, 1), // Border color
                    width: 1, // Border width
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              value: _selectedGroup?.isNotEmpty == true
                  ? _selectedGroup
                  : null, // Null-safe check for value
              items: _inkGroups.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedGroup =
                      newValue ?? ''; // Fallback to empty string if null
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an ink group';
                }
                return null;
              },
              iconEnabledColor: const Color.fromRGBO(100, 12, 227, 1),
              iconDisabledColor: const Color.fromRGBO(100, 12, 227, 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return GestureDetector(
      onTap: _pickColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: Text(
              'Reference Color',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(94, 93, 102, 1), // Label text color
              ),
            ),
          ),
          const SizedBox(height: 5), // Space between text and color picker
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedColor,
                  border: Border.all(
                      color: const Color.fromRGBO(234, 232, 254, 1), width: 1),
                ),
              ),
              const SizedBox(
                  width: 10), // Space between color display and picker
              const Text(
                'Tap to select a color',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isNumeric = false,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 170,
      height: 70, // Adjusted height to accommodate the label
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(94, 93, 102, 1), // Label text color
              ),
            ),
          ),
          const SizedBox(height: 0), // Space between label and text field
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey, // Hint text color
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromRGBO(234, 232, 254, 1), // Border color
                  width: 1, // Border width
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromRGBO(234, 232, 254, 1), // Border color
                  width: 1, // Border width
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black, // Text color
            ),
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            validator: validator,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Row for Brand and Ink Name
                Container(
                  margin: const EdgeInsets.only(left: 0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.cartridge == null
                        ? 'Add new cartridge'
                        : 'Edit Bottle',
                    style: const TextStyle(
                      color: Color.fromRGBO(67, 5, 157, 1),
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                _buildRow(
                  leftChild: _buildTextField(
                    controller: _brandController,
                    label: 'Brand',
                    hintText: 'Enter brand',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a brand';
                      }
                      return null;
                    },
                  ),
                  rightChild: _buildTextField(
                    controller: _inkNameController,
                    label: 'Ink Name',
                    hintText: 'Enter ink name',
                  ),
                ),
                const SizedBox(height: 10),

                // Row for Ink Color Picker and Ink Color Name
                _buildRow(
                  leftChild: _buildTextField(
                    controller: _inkColorNameController,
                    label: 'Ink Color Name',
                    hintText: 'Enter ink color name',
                  ),
                  rightChild: _buildColorPicker(),
                ),
                const SizedBox(height: 10),

                // Row for Ink Group (Dropdown) and Quantity
                _buildRow(
                  leftChild: _buildDropdown(
                    label: 'Ink Group',
                  ),
                  rightChild: _buildTextField(
                    controller: _quantityController,
                    label: 'Quantity',
                    hintText: 'Enter quantity',
                    isNumeric: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Quantity must be a number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Row for Price (Takes full width as it’s a single field)
                _buildRow(
                  leftChild: _buildTextField(
                    controller: _priceController,
                    label: 'Price',
                    hintText: 'Enter price',
                    isNumeric: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Price must be a number';
                      }
                      return null;
                    },
                  ),
                  rightChild:
                      const SizedBox(), // Empty widget to keep alignment
                ),
                const SizedBox(height: 20),

                // Image picker
                _buildImagePicker(),
                const SizedBox(height: 20),

                // Save button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(67, 5, 157, 1),
                    minimumSize: const Size(345, 35),
                  ),
                  onPressed: _saveCartridge,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
