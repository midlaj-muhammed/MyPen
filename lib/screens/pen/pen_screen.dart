import 'package:flutter/material.dart';
import 'dart:io'; // For File handling
import 'package:start2/screens/pen/add_edit.dart';
import 'package:start2/screens/pen/details_page.dart';
import 'package:start2/models/pen.dart';
import 'package:start2/services/pen.dart';

class PensScreen extends StatefulWidget {
  const PensScreen({super.key});

  @override
  _PensScreenState createState() => _PensScreenState();
}

class _PensScreenState extends State<PensScreen> {
  final PenService _penService = PenService();
  late Future<List<Pen>> _pensList;
  String? _selectedType; // Filter type variable
  bool _isAscending = true; // Sorting order (ascending or descending)
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _pensList = _penService.getPens(); // Initial fetch
  }

  Future<void> _refreshList() async {
    setState(() {
      if (_selectedType == null) {
        _pensList = _penService.getPens().then((pens) => pens.where((p) => p.brand.toLowerCase().contains(_searchQuery.toLowerCase()) || (p.model?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList());
      } else {
        _pensList = _penService.getPensByType(_selectedType!).then((pens) => pens.where((p) => p.brand.toLowerCase().contains(_searchQuery.toLowerCase()) || (p.model?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList());
      }
    });
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sort by Price'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Low to High'),
                onTap: () {
                  setState(() {
                    _isAscending = true; // Sort from low to high
                  });
                  Navigator.pop(context);
                  _sortList(); // Trigger sorting
                },
              ),
              ListTile(
                title: const Text('High to Low'),
                onTap: () {
                  setState(() {
                    _isAscending = false; // Sort from high to low
                  });
                  Navigator.pop(context);
                  _sortList(); // Trigger sorting
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sortList() async {
    setState(() {
      if (_isAscending) {
        _pensList = _penService.getPensSortedByPrice(true); // Low to High
      } else {
        _pensList = _penService.getPensSortedByPrice(false); // High to Low
      }
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
          margin:
              const EdgeInsets.only(right: 10), // Add consistent margin of 15
          child: _buildElevatedButton(),
        )
      ],
    );
  }

  ElevatedButton _buildSortButton() {
    return ElevatedButton(
      onPressed: _showSortDialog, // Show the sort dialog when pressed
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary, // Text color
        backgroundColor: Theme.of(context).colorScheme.primaryContainer, // Button color
        minimumSize: const Size(105, 35), // Button size
        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Text padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Border radius
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Sort By',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 5),
          Image.asset(
            'assets/icons/dropdown_icon.png', // Use your custom icon here
            width: 12,
            height: 7,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return ElevatedButton(
      onPressed: _showFilterDialog,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary, // Text color
        backgroundColor: Theme.of(context).colorScheme.primaryContainer, // Button color
        minimumSize: const Size(75, 35), // Button size
        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Text padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Border radius
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Show',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 5),
          Image.asset(
            'assets/icons/dropdown_icon.png', // Use your custom icon here
            width: 12,
            height: 7,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Pen Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Fountain'),
                onTap: () {
                  setState(() {
                    _selectedType = 'Fountain';
                  });
                  Navigator.pop(context);
                  _refreshList();
                },
              ),
              ListTile(
                title: const Text('Rollerball'),
                onTap: () {
                  setState(() {
                    _selectedType = 'Rollerball';
                  });
                  Navigator.pop(context);
                  _refreshList();
                },
              ),
              ListTile(
                title: const Text('Ballpoint'),
                onTap: () {
                  setState(() {
                    _selectedType = 'Ballpoint';
                  });
                  Navigator.pop(context);
                  _refreshList();
                },
              ),
              ListTile(
                title: const Text('Clear Filter'),
                onTap: () {
                  setState(() {
                    _selectedType = null; // Clear the filter
                  });
                  Navigator.pop(context);
                  _refreshList();
                },
              ),
            ],
          ),
        );
      },
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
              'My Pens',
              style: TextStyle(
                color: Color.fromRGBO(67, 5, 157, 1), // Text color
                fontSize: 30, // Font size
                fontWeight: FontWeight.w500, // Font weight
              ),
            ),
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0), // Add padding of 15
              child: _buildFilterButton(),
            ),
            const Spacer(), // This adds flexible space between the buttons
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: _buildSortButton(),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search pens by brand or model...',
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
        FutureBuilder<List<Pen>>(
          future: _pensList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading pens.'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child:
                        _buildEmptyState(), // Displaying the empty state button below sort and filter buttons
                  ),
                ],
              );
            } else {
              return Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshList,
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final pen = snapshot.data![index];
                      return _buildListItem(pen, index);
                    },
                  ),
                ),
              );
            }
          },
        )
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(left: 0, top: 5, right: 0),
      child: Center(
        child: SizedBox(
          width: 345, // Set width explicitly
          height: 150, // Set height explicitly
          child: OutlinedButton(
            onPressed: _navigateToAddEdit,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              side: WidgetStateProperty.all(
                const BorderSide(
                  color: Color.fromRGBO(234, 232, 254, 1),
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No pens added!',
                  style: TextStyle(
                    color: Color.fromRGBO(94, 93, 102, 1),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset(
                  'assets/icons/default_pen.png', // Default pen image
                ),
                const SizedBox(height: 10),
                const Text(
                  'Add YOUR FIRST PEN',
                  style: TextStyle(
                    color: Color.fromRGBO(100, 12, 227, 1),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(Pen pen, int index) {
    final image = _loadImage(pen.image);

    return InkWell(
      onTap: () => _navigateToDetails(pen, index), // Navigate to details on tap
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Container(
          width: 345,
          height: 200, // Adjusted height to accommodate the additional content
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
              Row(
                children: [
                  Text(
                    pen.brand,
                    style: const TextStyle(
                      color: Color.fromRGBO(121, 121, 121, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    pen.model ?? 'Unknown Model', // Handle null case
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                margin: const EdgeInsets.only(left: 250),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/pen_unselected.png', // Path to your icon
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      pen.nibStroke != null && pen.nibStroke!.isNotEmpty
                          ? pen.nibStroke![0].toUpperCase()
                          : '',
                      style: const TextStyle(
                        color: Color.fromRGBO(121, 121, 121, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      'assets/icons/ink_unselected.png', // Path to the second icon
                      width: 16,
                      height: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _loadImage(String imagePath) {
    return File(imagePath).existsSync()
        ? FileImage(File(imagePath))
        : const AssetImage('assets/icons/default_pen.png');
  }

  void _navigateToDetails(Pen pen, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PenDetailsScreen(pen: pen, index: index),
      ),
    ).then((_) => _refreshList());
  }

  ElevatedButton _buildElevatedButton() {
    return ElevatedButton(
      onPressed: _navigateToAddEdit,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer, // Text color
        minimumSize: const Size(75, 35), // Button size
        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Text padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Border radius
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
      MaterialPageRoute(builder: (context) => const AddEditPenScreen()),
    ).then((result) {
      if (result == true) {
        _refreshList();
      }
    });
  }
}
