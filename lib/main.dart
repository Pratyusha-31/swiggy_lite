import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

// Supabase credentials
const String supabaseUrl = 'https://ybboqfjmnyxiraqvqyff.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InliYm9xZmptbnl4aXJhcXZxeWZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2NDE5NzUsImV4cCI6MjA5MTIxNzk3NX0.NIl4xkvmQNbE-ePH4hxLqOPn9gHfvyQWqmwAESvxWao';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(
    ChangeNotifierProvider(create: (_) => CartProvider(), child: const MyApp()),
  );
}

final supabase = Supabase.instance.client;

// ─── CATEGORIES ──────────────────────────────────────────────────────────────
const List<String> kCategories = [
  'Biryani',
  'Rice',
  'Burgers',
  'Pizza',
  'Breakfast',
  'Drinks',
  'Snacks',
  'Desserts',
  'Noodles',
  'Sandwiches',
  'Thali',
  'Soups',
  'Other',
];

// Default images by category - user-provided stable food links
const Map<String, String> kDefaultImages = {
  'biryani': 'https://cdn.pixabay.com/photo/2019/11/04/12/16/rice-4601049_1280.jpg',
  'burgers': 'https://cdn.pixabay.com/photo/2016/03/05/19/02/hamburger-1238246_1280.jpg',
  'pizza': 'https://cdn.pixabay.com/photo/2017/12/10/14/47/pizza-3010062_1280.jpg',
  'breakfast': 'https://cdn.pixabay.com/photo/2016/11/06/23/31/breakfast-1804457_1280.jpg',
  'desserts': 'https://cdn.pixabay.com/photo/2016/10/31/18/14/dessert-1786311_1280.jpg',
  'drinks': 'https://images.pexels.com/photos/1283219/pexels-photo-1283219.jpeg?auto=compress&cs=tinysrgb&w=800',
  'snacks': 'https://images.pexels.com/photos/1583884/pexels-photo-1583884.jpeg?auto=compress&cs=tinysrgb&w=800',
'rice': 'https://images.pexels.com/photos/723198/pexels-photo-723198.jpeg',
  'noodles': 'https://images.pexels.com/photos/2347311/pexels-photo-2347311.jpeg?auto=compress&cs=tinysrgb&w=800',
  'sandwiches': 'https://images.pexels.com/photos/1633526/pexels-photo-1633526.jpeg?auto=compress&cs=tinysrgb&w=800',
'thali': 'https://images.pexels.com/photos/958545/pexels-photo-958545.jpeg',
  'soups': 'https://images.pexels.com/photos/1731535/pexels-photo-1731535.jpeg?auto=compress&cs=tinysrgb&w=800',
  'other': 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=800',
};

String? getDefaultImageUrl(String name, String category) {
  final catLower = category.toLowerCase();
  if (kDefaultImages.containsKey(catLower)) {
    return kDefaultImages[catLower];
  }
  final lower = name.toLowerCase();
  for (final key in kDefaultImages.keys) {
    if (lower.contains(key) || catLower.contains(key)) {
      return kDefaultImages[key];
    }
  }
  return null;
}

// ─── THEME ───────────────────────────────────────────────────────────────────
const kOrange = Color(0xFFFF6B00);
const kOrangeLight = Color(0xFFFF8C42);
const kDark = Color(0xFF1A1A2E);
const kSurface = Color(0xFF16213E);
const kCard = Color(0xFF0F3460);

// ─── CART PROVIDER ───────────────────────────────────────────────────────────
class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => _items;

  double get total =>
      _items.fold(0, (sum, item) => sum + (item['price'] * item['qty']));

  void add(Map<String, dynamic> item) {
    final index = _items.indexWhere((e) => e['id'] == item['id']);
    if (index >= 0) {
      _items[index]['qty']++;
    } else {
      _items.add({...item, 'qty': 1});
    }
    notifyListeners();
  }

  void remove(int id) {
    _items.removeWhere((e) => e['id'] == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

// ─── APP ─────────────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: kOrange,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── HOME SCREEN ─────────────────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kDark, kSurface, kCard],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [kOrange, kOrangeLight],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kOrange.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'FoodApp',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Delicious food, delivered fast',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 60),
                  _HomeButton(
                    icon: Icons.person_outline,
                    label: 'Order Food',
                    subtitle: 'Browse menu & order',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MenuScreen()),
                    ),
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),
                  _HomeButton(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin Panel',
                    subtitle: 'Manage menu & orders',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminLoginScreen()),
                    ),
                    isPrimary: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final VoidCallback onTap;
  final bool isPrimary;

  const _HomeButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(colors: [kOrange, kOrangeLight])
              : null,
          border: isPrimary
              ? null
              : Border.all(color: Colors.white.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
          color: isPrimary ? null : Colors.white.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withOpacity(0.2)
                    : kOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : kOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? Colors.white : Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPrimary
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isPrimary
                  ? Colors.white.withOpacity(0.7)
                  : Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── MENU SCREEN ─────────────────────────────────────────────────────────────
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final data = await supabase
        .from('menu_items')
        .select()
        .eq('is_available', true);
    setState(() {
      _items = List<Map<String, dynamic>>.from(data);
      _filtered = _items;
      _loading = false;
    });
  }

  void _filterByCategory(String cat) {
    setState(() {
      _selectedCategory = cat;
      _filtered = cat == 'All'
          ? _items
          : _items.where((e) => e['category'] == cat).toList();
    });
  }

  List<String> get _availableCategories {
    final cats = _items.map((e) => e['category'] as String? ?? '').toSet().toList();
    cats.removeWhere((c) => c.isEmpty);
    return ['All', ...cats];
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Menu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cart.items.length}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: kOrange),
            )
          : Column(
              children: [
                // Category filter chips
                SizedBox(
                  height: 56,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _availableCategories.length,
                    itemBuilder: (context, i) {
                      final cat = _availableCategories[i];
                      final selected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _filterByCategory(cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: selected ? kOrange : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: selected
                                      ? kOrange.withOpacity(0.3)
                                      : Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.grey.shade700,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Items
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(child: Text('No items available'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) {
                            final item = _filtered[i];
                            final isVeg = item['is_veg'] ?? true;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Image
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                    child: item['image_url'] != null &&
                                            item['image_url'].toString().isNotEmpty
                                        ? Image.network(
                                            item['image_url'],
                                            width: 100,
                                            height: 90,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _FoodPlaceholder(isVeg: isVeg),
                                          )
                                        : _FoodPlaceholder(isVeg: isVeg),
                                  ),
                                  // Details
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              // Veg/NonVeg indicator
                                              Container(
                                                width: 14,
                                                height: 14,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: isVeg
                                                        ? Colors.green
                                                        : Colors.red,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                                child: Center(
                                                  child: Container(
                                                    width: 7,
                                                    height: 7,
                                                    decoration: BoxDecoration(
                                                      color: isVeg
                                                          ? Colors.green
                                                          : Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  item['name'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['category'] ?? '',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '₹${item['price']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: kOrange,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  context
                                                      .read<CartProvider>()
                                                      .add(item);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          '${item['name']} added!'),
                                                      duration: const Duration(
                                                          seconds: 1),
                                                      backgroundColor: kOrange,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: kOrange,
                                                    borderRadius:
                                                        BorderRadius.circular(20),
                                                  ),
                                                  child: const Text(
                                                    'ADD',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _FoodPlaceholder extends StatelessWidget {
  final bool isVeg;
  const _FoodPlaceholder({required this.isVeg});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 90,
      color: isVeg
          ? Colors.green.shade50
          : Colors.red.shade50,
      child: Icon(
        isVeg ? Icons.eco : Icons.set_meal,
        color: isVeg ? Colors.green : Colors.red,
        size: 36,
      ),
    );
  }
}

// ─── CART SCREEN ─────────────────────────────────────────────────────────────
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Cart is empty!',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 18)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    itemBuilder: (context, i) {
                      final item = cart.items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('Qty: ${item['qty']}',
                                      style: TextStyle(
                                          color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                            Text(
                              '₹${item['price'] * item['qty']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kOrange,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  context.read<CartProvider>().remove(item['id']),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 18),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          Text(
                            '₹${cart.total}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: kOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 54),
                          backgroundColor: kOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PlaceOrderScreen()),
                        ),
                        child: const Text('Place Order',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── PLACE ORDER SCREEN ───────────────────────────────────────────────────────
class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});
  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;

  Future<void> _placeOrder() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields!')));
      return;
    }
    setState(() => _loading = true);
    final cart = context.read<CartProvider>();
    await supabase.from('orders').insert({
      'items': cart.items,
      'total': cart.total,
      'status': 'pending',
      'customer_name': _nameController.text,
      'customer_phone': _phoneController.text,
    });
    cart.clear();
    if (mounted) {
      setState(() => _loading = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
        (r) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Place Order',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildField(_nameController, 'Your Name', Icons.person_outline),
            const SizedBox(height: 16),
            _buildField(_phoneController, 'Phone Number', Icons.phone_outlined,
                isPhone: true),
            const SizedBox(height: 32),
            _loading
                ? const CircularProgressIndicator(color: kOrange)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: kOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _placeOrder,
                    child: const Text('Confirm Order',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController ctrl, String label, IconData icon,
      {bool isPhone = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kOrange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kOrange, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// ─── ORDER SUCCESS ────────────────────────────────────────────────────────────
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: Colors.green, size: 60),
            ),
            const SizedBox(height: 24),
            const Text('Order Placed!',
                style:
                    TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('We will deliver soon!',
                style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (r) => false,
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ADMIN LOGIN ──────────────────────────────────────────────────────────────
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _passController = TextEditingController();
  bool _obscure = true;
  final _adminPassword = 'admin123';

  void _login() {
    if (_passController.text == _adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanel()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrong password!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kDark, kSurface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kOrange.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: kOrange.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(Icons.admin_panel_settings,
                        size: 60, color: kOrange),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Admin Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter password to continue',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _passController,
                    obscureText: _obscure,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.6)),
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: kOrange),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: kOrange, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: kOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _login,
                    child: const Text('Login',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── ADMIN PANEL ──────────────────────────────────────────────────────────────
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});
  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Admin Panel',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: kOrange,
          unselectedLabelColor: Colors.white60,
          indicatorColor: kOrange,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Menu'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [AdminMenuTab(), AdminOrdersTab()],
      ),
    );
  }
}

// ─── ADMIN MENU TAB ───────────────────────────────────────────────────────────
class AdminMenuTab extends StatefulWidget {
  const AdminMenuTab({super.key});
  @override
  State<AdminMenuTab> createState() => _AdminMenuTabState();
}

class _AdminMenuTabState extends State<AdminMenuTab> {
  List<Map<String, dynamic>> _items = [];
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _selectedCategory = kCategories.first;
  bool _isVeg = true;
  String? _imageUrl;
  bool _uploading = false;
XFile? _pickedImage;
  Uint8List? _imageBytes;
  bool _manualImageSelected = false;

  @override
  void initState() {
    super.initState();
    _load();
    // Auto-fill image when name changes
    _nameCtrl.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (!_manualImageSelected && (_imageUrl == null || _imageUrl!.isEmpty)) {
      final suggested = getDefaultImageUrl(_nameCtrl.text, _selectedCategory);
      if (suggested != null) {
        setState(() => _imageUrl = suggested);
      }
    }
  }

  Future<void> _load() async {
    final data = await supabase.from('menu_items').select();
    setState(() => _items = List<Map<String, dynamic>>.from(data));
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
  final picked =
      await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  if (picked == null) return;

  final bytes = await picked.readAsBytes();
  setState(() {
    _pickedImage = picked;
    _imageBytes = bytes;
    _uploading = true;
  });

    try {
      final bytes = await picked.readAsBytes();
      final fileName =
          'food_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('food-images').uploadBinary(
            fileName,
            bytes,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      final url = supabase.storage
          .from('food-images')
          .getPublicUrl(fileName);
      setState(() {
        _imageUrl = url;
        _manualImageSelected = true;
        _uploading = false;
      });
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _addItem() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name and Price required!')));
      return;
    }
    await supabase.from('menu_items').insert({
      'name': _nameCtrl.text,
      'price': double.parse(_priceCtrl.text),
      'category': _selectedCategory,
      'is_veg': _isVeg,
      'image_url': _imageUrl ?? '',
      'is_available': true,
    });
    _nameCtrl.clear();
    _priceCtrl.clear();
    setState(() {
      _selectedCategory = kCategories.first;
      _isVeg = true;
      _imageUrl = null;
      _manualImageSelected = false;
_pickedImage = null;
    });
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Item added!'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _toggle(int id, bool current) async {
    await supabase
        .from('menu_items')
        .update({'is_available': !current}).eq('id', id);
    _load();
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await supabase.from('menu_items').delete().eq('id', id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ── ADD ITEM FORM ──
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_circle_outline,
                          color: kOrange, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Add New Item',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Item Name
                TextField(
                  controller: _nameCtrl,
                  decoration: _inputDeco('Item Name', Icons.fastfood_outlined),
                ),
                const SizedBox(height: 12),

                // Price
                TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco('Price (₹)', Icons.currency_rupee),
                ),
                const SizedBox(height: 12),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _inputDeco('Category', Icons.category_outlined),
                  items: kCategories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val!;
                      // Auto suggest image on category change too (manual priority)
                      if (!_manualImageSelected) {
                        final suggested = getDefaultImageUrl(
                            _nameCtrl.text, _selectedCategory);
                        if (suggested != null) _imageUrl = suggested;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Veg / Non-Veg Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isVeg = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isVeg ? Colors.green : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: _isVeg
                                            ? Colors.white
                                            : Colors.green,
                                        width: 1.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _isVeg
                                            ? Colors.white
                                            : Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Veg',
                                  style: TextStyle(
                                    color:
                                        _isVeg ? Colors.white : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isVeg = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isVeg ? Colors.red : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: !_isVeg
                                            ? Colors.white
                                            : Colors.red,
                                        width: 1.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: !_isVeg
                                            ? Colors.white
                                            : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Non-Veg',
                                  style: TextStyle(
                                    color:
                                        !_isVeg ? Colors.white : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Image Section
                const Text(
                  'Food Image',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade100,
                        child: _uploading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: kOrange, strokeWidth: 2))
                            : _pickedImage != null
? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                : _imageUrl != null &&
                                        _imageUrl!.isNotEmpty
                                    ? Image.network(_imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image,
                                                color: Colors.grey))
                                    : const Icon(Icons.image_outlined,
                                        color: Colors.grey, size: 36),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _uploading ? null : _pickAndUpload,
                            icon: const Icon(Icons.upload_outlined, size: 16),
                            label: const Text('Upload Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kOrange,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 38),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (_imageUrl != null && _imageUrl!.isNotEmpty)
                            Text(
                              '✓ Image ready',
                              style: TextStyle(
                                  color: Colors.green.shade600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500),
                            )
                          else
                            Text(
                              'Auto-filled from item name',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Add Button
                ElevatedButton(
                  onPressed: _uploading ? null : _addItem,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    backgroundColor: kDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Add Item',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── ITEMS LIST ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'All Items (${_items.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _items.length,
            itemBuilder: (context, i) {
              final item = _items[i];
              final isVeg = item['is_veg'] ?? true;
              final isAvail = item['is_available'] ?? true;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                      child: item['image_url'] != null &&
                              item['image_url'].toString().isNotEmpty
                          ? Image.network(
                              item['image_url'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _AdminImagePlaceholder(isVeg: isVeg),
                            )
                          : _AdminImagePlaceholder(isVeg: isVeg),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: isVeg
                                            ? Colors.green
                                            : Colors.red,
                                        width: 1.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isVeg
                                            ? Colors.green
                                            : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: kOrange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['category'] ?? '',
                                    style: const TextStyle(
                                        color: kOrange,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '₹${item['price']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: kOrange,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Controls
                    Column(
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: isAvail,
                            onChanged: (_) =>
                                _toggle(item['id'], isAvail),
                            activeColor: Colors.green,
                          ),
                        ),
                        Text(
                          isAvail ? 'On' : 'Off',
                          style: TextStyle(
                            fontSize: 10,
                            color: isAvail ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _delete(item['id']),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.only(right: 8, bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: kOrange, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kOrange, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}

class _AdminImagePlaceholder extends StatelessWidget {
  final bool isVeg;
  const _AdminImagePlaceholder({required this.isVeg});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: isVeg ? Colors.green.shade50 : Colors.red.shade50,
      child: Icon(
        isVeg ? Icons.eco : Icons.set_meal,
        color: isVeg ? Colors.green : Colors.red,
        size: 30,
      ),
    );
  }
}

// ─── ADMIN ORDERS TAB ─────────────────────────────────────────────────────────
class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});
  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await supabase
        .from('orders')
        .select()
        .order('created_at', ascending: false);
    setState(() {
      _orders = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  Future<void> _updateStatus(int id, String status) async {
    await supabase
        .from('orders')
        .update({'status': status}).eq('id', id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: kOrange));
    }
    return _orders.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('No orders yet',
                    style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _load,
            color: kOrange,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _orders.length,
              itemBuilder: (context, i) {
                final order = _orders[i];
                final status = order['status'] ?? 'pending';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order['id']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            _StatusBadge(status: status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person_outline,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(order['customer_name'] ?? '',
                                style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 12),
                            const Icon(Icons.phone_outlined,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(order['customer_phone'] ?? '',
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${order['total']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kOrange,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        const Text(
                          'Update Status',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _StatusButton(
                              label: 'Pending',
                              status: 'pending',
                              current: status,
                              id: order['id'],
                              onTap: _updateStatus,
                            ),
                            const SizedBox(width: 8),
                            _StatusButton(
                              label: 'Preparing',
                              status: 'preparing',
                              current: status,
                              id: order['id'],
                              onTap: _updateStatus,
                            ),
                            const SizedBox(width: 8),
                            _StatusButton(
                              label: 'Delivered',
                              status: 'delivered',
                              current: status,
                              id: order['id'],
                              onTap: _updateStatus,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get color {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'preparing': return Colors.blue;
      case 'delivered': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData get icon {
    switch (status) {
      case 'pending': return Icons.hourglass_empty;
      case 'preparing': return Icons.restaurant;
      case 'delivered': return Icons.check_circle_outline;
      default: return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label, status, current;
  final int id;
  final Function(int, String) onTap;

  const _StatusButton({
    required this.label,
    required this.status,
    required this.current,
    required this.id,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = current == status;
    Color color;
    switch (status) {
      case 'pending': color = Colors.orange; break;
      case 'preparing': color = Colors.blue; break;
      case 'delivered': color = Colors.green; break;
      default: color = Colors.grey;
    }
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(id, status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? color : color.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}