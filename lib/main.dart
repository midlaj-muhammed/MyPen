import 'package:firebase_core/firebase_core.dart';
import 'package:start2/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:start2/screens/auth/auth_wrapper.dart';
import 'package:start2/screens/bottle/bottle_screen.dart';
import 'package:start2/screens/cartridge/cartridge_screen.dart';
import 'package:start2/screens/pen/pen_screen.dart';
import 'models/pen.dart';
import 'models/bottle.dart';
import 'models/cartridge.dart';
import 'models/wishlist_item.dart';
import 'package:start2/services/secure_storage.dart';
import 'package:start2/screens/profile/profile_screen.dart';
import 'package:start2/screens/wishlist/wishlist_screen.dart';
import 'package:start2/screens/analytics/analytics_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb
        ? DefaultFirebaseOptions.web
        : DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(PenAdapter());
  Hive.registerAdapter(BottleAdapter());
  Hive.registerAdapter(CartridgeAdapter());
  Hive.registerAdapter(WishlistItemAdapter());

  var cipher = await SecureStorage.getCipher();

  await Hive.openBox<Pen>('pens', encryptionCipher: cipher);
  await Hive.openBox<Bottle>('bottles', encryptionCipher: cipher);
  await Hive.openBox<Cartridge>('cartridges', encryptionCipher: cipher);
  await Hive.openBox<WishlistItem>('wishlist', encryptionCipher: cipher);
  await Hive.openBox('settings');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPen',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color.fromRGBO(249, 249, 255, 1),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF43059D)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(249, 249, 255, 1),
          foregroundColor: Colors.black,
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    PensScreen(),
    InksTab(),
    WishlistScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 8.0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icons/pen_unselected.png')),
            activeIcon: ImageIcon(AssetImage('assets/icons/pen_selected.png')),
            label: 'Pens',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icons/ink_unselected.png')),
            activeIcon: ImageIcon(AssetImage('assets/icons/ink_selected.png')),
            label: 'Inks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class InksTab extends StatefulWidget {
  const InksTab({super.key});

  @override
  _InksTabState createState() => _InksTabState();
}

class _InksTabState extends State<InksTab> {
  int _currentIndex = 0;
  final List<Widget> _inkTabs = [
    const BottlesScreen(),
    const CartridgesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTabs(),
          ),
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            bottom: 0,
            child: _inkTabs[_currentIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem('Bottles', 0),
          _buildBottomNavItem('Cartridges', 1),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(String label, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        width: 75,
        height: 25,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
