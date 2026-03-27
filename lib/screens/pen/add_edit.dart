import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:start2/models/pen.dart';
import 'package:start2/services/pen.dart';
import 'package:path/path.dart' as path;

class AddEditPenScreen extends StatefulWidget {
  final Pen? pen;
  final int? index;

  const AddEditPenScreen({super.key, this.pen, this.index});

  @override
  _AddEditPenScreenState createState() => _AddEditPenScreenState();
}

class _AddEditPenScreenState extends State<AddEditPenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();
  final _typeController = TextEditingController();
  final _modelController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  final _priceController = TextEditingController();
  final _nibMaterialController = TextEditingController();
  final _nibPlattingController = TextEditingController();
  File? _imageFile;
  final PenService _penService = PenService();

  // Example predefined values for dropdowns
  final List<String> _penTypes = ['Fountain', 'Rollerball', 'Ballpoint'];
  final List<String> _penMaterials = ['Plastic', 'Metal', 'Wood'];
  final List<String> _penGroups = ['Group A', 'Group B', 'Group C'];
  final List<String> _nibStrokes = ['Fine', 'Medium', 'Broad'];
  final List<String> _nibMaterials = [
    'Steel',
    'Gold',
    'Titanium'
  ]; // Added Nib Materials
  final List<String> _nibPlatings = [
    'Rhodium',
    'Platinum',
    'Silver'
  ]; // Added Nib Platings

  String? _selectedType;
  String? _selectedMaterial;
  String? _selectedGroup;
  String? _selectedNibStroke;
  String? _selectedNibMaterial;
  String? _selectedNibPlating;

  @override
  void initState() {
    super.initState();
    if (widget.pen != null) {
      _populateFields(widget.pen!);
      _imageFile = File(widget.pen!.image);
    }
    // Ensure initial values for dropdowns
    _selectedMaterial =
        _penMaterials.contains(_selectedMaterial) ? _selectedMaterial : null;
    _selectedGroup =
        _penGroups.contains(_selectedGroup) ? _selectedGroup : null;
    _selectedNibStroke =
        _nibStrokes.contains(_selectedNibStroke) ? _selectedNibStroke : null;
    _selectedNibMaterial = _nibMaterials.contains(_selectedNibMaterial)
        ? _selectedNibMaterial
        : null;
    _selectedNibPlating =
        _nibPlatings.contains(_selectedNibPlating) ? _selectedNibPlating : null;
  }

  void _populateFields(Pen pen) {
    _brandController.text = pen.brand;
    _colorController.text = pen.color ?? '';
    _modelController.text = pen.model ?? '';
    _selectedMaterial =
        _penMaterials.contains(pen.penMaterial) ? pen.penMaterial : null;
    _selectedGroup = _penGroups.contains(pen.penGroup) ? pen.penGroup : null;
    _purchaseDateController.text = pen.purchaseDate?.toString() ?? '';
    _priceController.text = pen.price?.toString() ?? '';
    _selectedNibStroke =
        _nibStrokes.contains(pen.nibStroke) ? pen.nibStroke : null;
    _selectedNibMaterial =
        _nibMaterials.contains(pen.nibMaterial) ? pen.nibMaterial : null;
    _selectedNibPlating =
        _nibPlatings.contains(pen.nibPlatting) ? pen.nibPlatting : null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _brandController.dispose();
    _colorController.dispose();
    _typeController.dispose();
    _modelController.dispose();
    _purchaseDateController.dispose();
    _priceController.dispose();
    _nibMaterialController.dispose();
    _nibPlattingController.dispose();
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

  void _savePen() async {
    final pen = await _createPen(); // Await the pen creation
    if (widget.index == null) {
      await _penService.addPen(pen);
    } else {
      await _penService.updatePen(widget.index!, pen);
    }
    Navigator.pop(context, true);
  }

  Future<Pen> _createPen() async {
    Pen? existingPen;

    // Fetch the list of pens asynchronously
    final pens = await _penService.getPens();

    // Check if there is a pen at the specific index if editing
    if (widget.index != null && widget.index! < pens.length) {
      existingPen = pens[widget.index!];
    }

    // Ensure the inkId remains the same if not updated by the user
    final inkId = existingPen?.inkId ??
        'bottle-${DateTime.now().millisecondsSinceEpoch}'; // Keep existing inkId if editing

    return Pen(
      brand: _brandController.text.isNotEmpty
          ? _brandController.text
          : existingPen?.brand ?? '',
      image: _imageFile?.path ?? existingPen?.image ?? '',
      inkId: inkId,
      color: _colorController.text.isNotEmpty
          ? _colorController.text
          : existingPen?.color ?? '',
      type: _selectedType ?? existingPen?.type ?? '',
      model: _modelController.text.isNotEmpty
          ? _modelController.text
          : existingPen?.model ?? '',
      penMaterial: _selectedMaterial ?? existingPen?.penMaterial ?? '',
      penGroup: _selectedGroup ?? existingPen?.penGroup ?? '',
      purchaseDate: _purchaseDateController.text.isNotEmpty
          ? DateTime.tryParse(_purchaseDateController.text)
          : existingPen?.purchaseDate,
      price: _priceController.text.isNotEmpty
          ? double.tryParse(_priceController.text)
          : existingPen?.price,
      nibStroke: _selectedNibStroke ?? existingPen?.nibStroke ?? '',
      nibMaterial: _selectedNibMaterial ?? existingPen?.nibMaterial ?? '',
      nibPlatting: _selectedNibPlating ?? existingPen?.nibPlatting ?? '',
      sessions: existingPen?.sessions ??
          [], // Use existing sessions if editing, or initialize empty list if new
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    widget.pen == null ? 'Add new pen' : 'Edit Pen',
                    style: const TextStyle(
                      color: Color.fromRGBO(67, 5, 157, 1),
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Type',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(94, 93, 102, 1),
                              ),
                            ),
                          ),
                          _buildDropdownField(_penTypes, 'Type', _selectedType,
                              (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Brand',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(94, 93, 102, 1),
                              ),
                            ),
                          ),
                          _buildTextField(_brandController, 'Brand',
                              'Please enter a brand', 'Enter brand'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Model',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(94, 93, 102, 1),
                              ),
                            ),
                          ),
                          _buildTextField(_modelController, 'Model',
                              'Enter model', 'Enter model'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Color',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(94, 93, 102, 1),
                              ),
                            ),
                          ),
                          _buildTextField(_colorController, 'Color',
                              'Enter color', 'Enter color'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Text(
                    'Image',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(94, 93, 102, 1),
                    ),
                  ),
                ),
                _buildImagePicker(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Material',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(94, 93, 102, 1),
                              ),
                            ),
                          ),
                          _buildDropdownField(
                              _penMaterials, 'Material', _selectedMaterial,
                              (value) {
                            setState(() {
                              _selectedMaterial = value;
                            });
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Group',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(94, 93, 102, 1),
                              ),
                            ),
                          ),
                          _buildDropdownField(
                              _penGroups, 'Group', _selectedGroup, (value) {
                            setState(() {
                              _selectedGroup = value;
                            });
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Purchase Date',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(94, 93, 102, 1),
                              ),
                            ),
                          ),
                          _buildDateField(context, _purchaseDateController,
                              'Purchase Date'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(94, 93, 102, 1),
                              ),
                            ),
                          ),
                          _buildTextField(_priceController, 'Price',
                              'Please enter a price', 'Enter price')
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Nib Stroke',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(94, 93, 102, 1),
                              ),
                            ),
                          ),
                          _buildDropdownField(
                              _nibStrokes, 'Nib Stroke', _selectedNibStroke,
                              (value) {
                            setState(() {
                              _selectedNibStroke = value;
                            });
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Nib Material',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(94, 93, 102, 1),
                              ),
                            ),
                          ),
                          _buildDropdownField(_nibMaterials, 'Nib Material',
                              _selectedNibMaterial, (value) {
                            setState(() {
                              _selectedNibMaterial = value;
                            });
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Text(
                    'Nib Plating',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(94, 93, 102, 1),
                    ),
                  ),
                ),
                _buildDropdownField(
                    _nibPlatings, 'Nib Plating', _selectedNibPlating, (value) {
                  setState(() {
                    _selectedNibPlating = value;
                  });
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _savePen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(67, 5, 157, 1),
                    minimumSize: const Size(345, 35),
                  ),
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(249, 249, 255, 1),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: SizedBox(
            width: 75,
            height: 35,
            child: ElevatedButton(
              onPressed: _savePen,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                foregroundColor: const Color.fromRGBO(100, 12, 227, 1),
                backgroundColor:
                    const Color.fromRGBO(234, 232, 254, 1), // Text color
                minimumSize: const Size(75, 35), // Button size
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0), // Text padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Border radius
                ),
              ),
              child: const Text('Save'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [String? validatorMessage, String? hintText]) {
    return SizedBox(
      width: 170,
      height: 50,
      child: TextFormField(
        controller: controller,
        textCapitalization:
            TextCapitalization.sentences, // Capitalize first letter
        decoration: InputDecoration(
          hintText: hintText, // This is the hint text
          hintStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey, // Hint text color
          ),
          labelText: null, // Ensure labelText is null for hintText to show
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
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDropdownField(List<String> items, String label,
      String? selectedValue, Function(String?) onChanged) {
    return SizedBox(
      width: 170,
      height: 50,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: null, // Remove default label text
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black,
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
          hintText: 'Select $label', // Ensure hint text is always displayed
          hintStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
        value: selectedValue,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ), // Ensures text is visible
            ),
          );
        }).toList(),
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ), // Ensures selected text is visible
        iconEnabledColor:
            const Color.fromRGBO(100, 12, 227, 1), // Change icon color
        iconDisabledColor:
            const Color.fromRGBO(100, 12, 227, 1), // Change icon color
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context, TextEditingController controller, String label) {
    return SizedBox(
      width: 170,
      height: 50,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey), // Use a darker color
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
          color: Colors.black,
        ),
        readOnly: true,
        onTap: () => _selectPurchaseDate(context),
      ),
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
              : _imageFile!.path.isNotEmpty
                  ? Image.file(_imageFile!, width: 100, height: 100)
                  : Expanded(
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
                    ),
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

  Future<void> _selectPurchaseDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _purchaseDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
}
