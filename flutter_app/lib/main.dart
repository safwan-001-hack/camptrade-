import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// SUPABASE_URL and SUPABASE_ANON_KEY are injected at build time via
// --dart-define in codemagic.yaml. If they're missing, auth features
// simply won't work, but the rest of the app still runs (guest mode).
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    } catch (_) {
      // App still runs in guest/local mode if Supabase init fails.
    }
  }
  runApp(const CampTradeApp());
}

SupabaseClient? get _supabaseOrNull {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}

// =========================================================
// Models
// =========================================================

class Campus {
  final String id;
  final String name;
  final String location;
  final Color themeColor;
  final int trustedCount;

  const Campus({
    required this.id,
    required this.name,
    required this.location,
    required this.themeColor,
    required this.trustedCount,
  });
}

class Product {
  final String id;
  final String campusId;
  final String title;
  final String seller;
  final double price;
  final String category;
  final IconData icon;
  final String description;

  const Product({
    required this.id,
    required this.campusId,
    required this.title,
    required this.seller,
    required this.price,
    required this.category,
    required this.icon,
    required this.description,
  });
}

class WantedPost {
  final String id;
  final String campusId;
  final String title;
  final String budget;
  final String postedBy;

  const WantedPost({
    required this.id,
    required this.campusId,
    required this.title,
    required this.budget,
    required this.postedBy,
  });
}

class OrderRecord {
  final String id;
  final Product product;
  String status;

  OrderRecord({required this.id, required this.product, this.status = 'Pending'});
}

class Announcement {
  final String title;
  final String date;
  const Announcement(this.title, this.date);
}

// =========================================================
// App-wide state (no external packages needed — plain
// ChangeNotifier + InheritedNotifier, both built into Flutter)
// =========================================================

class AppData extends ChangeNotifier {
  final List<Campus> campuses = [
    const Campus(
      id: 'newgate',
      name: 'Newgate University',
      location: 'Minna, Niger State',
      themeColor: Color(0xFF2E86C1),
      trustedCount: 5000,
    ),
    const Campus(
      id: 'ibbu',
      name: 'Ibrahim Badamasi Babangida University',
      location: 'Lapai, Niger State',
      themeColor: Color(0xFF1E8449),
      trustedCount: 8500,
    ),
    const Campus(
      id: 'ftu',
      name: 'Federal University of Technology, Minna',
      location: 'Niger State',
      themeColor: Color(0xFF6C3483),
      trustedCount: 10000,
    ),
  ];

  late Campus currentCampus = campuses.last; // default to FUT Minna

  final List<Product> products = [
    const Product(id: 'p1', campusId: 'ftu', title: 'HP Laptop 15.6"', seller: 'TechWorld', price: 280000, category: 'Electronics', icon: Icons.laptop_mac, description: 'Core i5, 8GB RAM, light use, charger included.'),
    const Product(id: 'p2', campusId: 'ftu', title: 'Nike Air Force 1', seller: 'SneakerHub', price: 45000, category: 'Fashion', icon: Icons.checkroom, description: 'Size 42, worn twice, no marks.'),
    const Product(id: 'p3', campusId: 'ftu', title: 'Textbooks (100 Level)', seller: 'Campus Books', price: 12000, category: 'Books', icon: Icons.menu_book, description: 'Full set for 100L Engineering, good condition.'),
    const Product(id: 'p4', campusId: 'ftu', title: 'iPhone 11', seller: 'GadgetWorld', price: 180000, category: 'Electronics', icon: Icons.smartphone, description: 'Battery health 87%, no cracks, unlocked.'),
    const Product(id: 'p5', campusId: 'ftu', title: 'School Backpack', seller: 'Campus Essentials', price: 15000, category: 'Fashion', icon: Icons.backpack, description: 'Water resistant, laptop compartment.'),
    const Product(id: 'p6', campusId: 'newgate', title: 'HP Laptop 15.6"', seller: 'TechWorld', price: 280000, category: 'Electronics', icon: Icons.laptop_mac, description: 'Core i5, 8GB RAM, light use, charger included.'),
    const Product(id: 'p7', campusId: 'newgate', title: 'Bluetooth Speaker', seller: 'SoundHub', price: 18500, category: 'Electronics', icon: Icons.speaker, description: 'Portable, 10hr battery, barely used.'),
    const Product(id: 'p8', campusId: 'ibbu', title: 'Textbooks (100 Level)', seller: 'Campus Books', price: 12000, category: 'Books', icon: Icons.menu_book, description: 'Full set for 100L courses, good condition.'),
    const Product(id: 'p9', campusId: 'ibbu', title: 'Reading Table', seller: 'HostelDeals', price: 22000, category: 'Home & Living', icon: Icons.table_bar, description: 'Wooden, sturdy, pickup only.'),
  ];

  final List<WantedPost> wantedPosts = [
    const WantedPost(id: 'w1', campusId: 'ftu', title: 'Looking for a used graphics calculator', budget: '\u20a68,000', postedBy: 'Sarah A.'),
    const WantedPost(id: 'w2', campusId: 'newgate', title: 'Need a mini fridge for hostel room', budget: '\u20a635,000', postedBy: 'David O.'),
  ];

  final Map<String, List<Announcement>> announcements = {
    'newgate': const [
      Announcement('Newgate University Inter-Departmental Games', 'Apr 25, 2025'),
      Announcement('School Fees Payment Deadline Extended', 'Apr 22, 2025'),
      Announcement('WAEC Registration Now Open', 'Apr 20, 2025'),
    ],
    'ibbu': const [
      Announcement('IBBU Sports Festival Registration Now Open', 'Apr 26, 2025'),
      Announcement('School Fees Payment Deadline Extended', 'Apr 24, 2025'),
      Announcement('WAEC Registration Now Open', 'Apr 22, 2025'),
    ],
    'ftu': const [
      Announcement('School fees payment deadline extended', 'Apr 26, 2025'),
      Announcement('FTU Minna Annual Sports Festival', 'Apr 25, 2025'),
      Announcement('WAEC Registration Now Open', 'Apr 22, 2025'),
    ],
  };

  final Set<String> favoriteIds = {};
  final List<OrderRecord> orders = [];
  User? currentUser;
  bool guestMode = false;

  List<Product> productsForCurrentCampus() =>
      products.where((p) => p.campusId == currentCampus.id).toList();

  List<WantedPost> wantedForCurrentCampus() =>
      wantedPosts.where((w) => w.campusId == currentCampus.id).toList();

  List<Announcement> announcementsForCurrentCampus() =>
      announcements[currentCampus.id] ?? const [];

  void switchCampus(Campus c) {
    currentCampus = c;
    notifyListeners();
  }

  void addCampus({required String name, required String location, required Color color}) {
    final id = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final campus = Campus(id: id, name: name, location: location, themeColor: color, trustedCount: 0);
    campuses.add(campus);
    announcements[id] = const [];
    currentCampus = campus;
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    if (favoriteIds.contains(productId)) {
      favoriteIds.remove(productId);
    } else {
      favoriteIds.add(productId);
    }
    notifyListeners();
  }

  void addProduct(Product product) {
    products.insert(0, product);
    notifyListeners();
  }

  void addWantedPost(WantedPost post) {
    wantedPosts.insert(0, post);
    notifyListeners();
  }

  void placeOrder(Product product) {
    orders.insert(0, OrderRecord(id: 'o${DateTime.now().millisecondsSinceEpoch}', product: product));
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    final client = _supabaseOrNull;
    if (client == null) return 'Supabase is not configured.';
    try {
      final res = await client.auth.signInWithPassword(email: email, password: password);
      currentUser = res.user;
      guestMode = false;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Login error: $e';
    }
  }

  Future<String?> signUp(String email, String password) async {
    final client = _supabaseOrNull;
    if (client == null) return 'Supabase is not configured.';
    try {
      final res = await client.auth.signUp(email: email, password: password);
      currentUser = res.user;
      guestMode = false;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Could not create account: that email may already be in use.';
    }
  }

  void continueAsGuest() {
    guestMode = true;
    notifyListeners();
  }

  void signOut() {
    _supabaseOrNull?.auth.signOut();
    currentUser = null;
    guestMode = false;
    notifyListeners();
  }

  bool get isLoggedIn => currentUser != null || guestMode;
}

class AppDataScope extends InheritedNotifier<AppData> {
  const AppDataScope({super.key, required AppData data, required super.child}) : super(notifier: data);

  static AppData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppDataScope>();
    return scope!.notifier!;
  }
}

// =========================================================
// Root app
// =========================================================

class CampTradeApp extends StatefulWidget {
  const CampTradeApp({super.key});

  @override
  State<CampTradeApp> createState() => _CampTradeAppState();
}

class _CampTradeAppState extends State<CampTradeApp> {
  final AppData appData = AppData();

  @override
  Widget build(BuildContext context) {
    return AppDataScope(
      data: appData,
      child: AnimatedBuilder(
        animation: appData,
        builder: (context, _) {
          final accent = appData.currentCampus.themeColor;
          return MaterialApp(
            title: 'CampTrade',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: accent,
              scaffoldBackgroundColor: const Color(0xFFF6F7F9),
              appBarTheme: AppBarTheme(backgroundColor: accent, foregroundColor: Colors.white, elevation: 0),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(selectedItemColor: accent),
            ),
            home: appData.isLoggedIn ? const RootShell() : const LoginScreen(),
          );
        },
      ),
    );
  }
}

// =========================================================
// Login
// =========================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final data = AppDataScope.of(context);
    setState(() { _loading = true; _error = null; });
    final error = _isRegister
        ? await data.signUp(_emailController.text.trim(), _passwordController.text)
        : await data.signIn(_emailController.text.trim(), _passwordController.text);
    if (mounted) setState(() { _loading = false; _error = error; });
  }

  @override
  Widget build(BuildContext context) {
    final data = AppDataScope.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF171A21),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CampTrade', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              const Text('Your Campus. Your Market.', style: TextStyle(color: Color(0xFF9CA3B5), fontSize: 13)),
              const Spacer(),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Color(0xFF9CA3B5))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: Color(0xFF9CA3B5))),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12.5)),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isRegister ? 'Create account' : 'Log in'),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _isRegister = !_isRegister),
                child: Text(
                  _isRegister ? 'Already have an account? Log in' : "New here? Create an account",
                  style: const TextStyle(color: Color(0xFF9CA3B5)),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: data.continueAsGuest,
                  child: const Text('Continue as guest', style: TextStyle(color: Colors.white70)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================
// Root shell (bottom tabs)
// =========================================================

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const WantedScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), label: 'Wanted'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// =========================================================
// Home / Marketplace
// =========================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  String? _category;

  static const _categories = [
    ['Electronics', Icons.laptop_mac],
    ['Fashion', Icons.checkroom],
    ['Books', Icons.menu_book],
    ['Health & Beauty', Icons.spa_outlined],
    ['Food & Drinks', Icons.restaurant_outlined],
    ['Home & Living', Icons.chair_outlined],
  ];

  @override
  Widget build(BuildContext context) {
    final data = AppDataScope.of(context);
    final campus = data.currentCampus;
    final accent = campus.themeColor;

    var items = data.productsForCurrentCampus();
    if (_category != null) items = items.where((p) => p.category == _category).toList();
    if (_query.isNotEmpty) items = items.where((p) => p.title.toLowerCase().contains(_query.toLowerCase())).toList();

    final announcements = data.announcementsForCurrentCampus();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Container(
              width: double.infinity,
              color: accent,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => showCampusSwitcher(context),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(campus.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                              Text(campus.location, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.expand_more, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('CampTrade', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  const Text('Your Campus. Your Market.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search for products, categories, sellers...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text('Trusted by ${campus.trustedCount}+ students', style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sell / Wanted quick actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddListingScreen())),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Sell'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddWantedScreen())),
                      icon: Icon(Icons.campaign_outlined, size: 18, color: accent),
                      label: Text('Wanted', style: TextStyle(color: accent)),
                    ),
                  ),
                ],
              ),
            ),

            // Categories
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: _categories.map((c) {
                  final name = c[0] as String;
                  final icon = c[1] as IconData;
                  final selected = _category == name;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: InkWell(
                      onTap: () => setState(() => _category = selected ? null : name),
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: selected ? accent : accent.withOpacity(0.12),
                            child: Icon(icon, color: selected ? Colors.white : accent, size: 20),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(width: 70, child: Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5))),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Announcements
            if (announcements.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Text('Campus Announcements', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: accent)),
              ),
              SizedBox(
                height: 64,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: announcements.length,
                  itemBuilder: (context, i) {
                    final a = announcements[i];
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE7E7EA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text(a.date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],

            // Featured products
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Text('Marketplace', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: accent)),
            ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: Text('No products match your search on this campus yet.', textAlign: TextAlign.center)),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.78,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final p = items[i];
                  final favorited = data.favoriteIds.contains(p.id);
                  return InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE7E7EA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.08),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                  ),
                                  child: Icon(p.icon, size: 48, color: accent),
                                ),
                                Positioned(
                                  top: 6, right: 6,
                                  child: InkWell(
                                    onTap: () => data.toggleFavorite(p.id),
                                    customBorder: const CircleBorder(),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                                      child: Icon(favorited ? Icons.favorite : Icons.favorite_border, size: 14, color: accent),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(9, 8, 9, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text('\u20a6${p.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: accent)),
                                Text(p.seller, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// Campus switcher + Add university (admin)
// =========================================================

void showCampusSwitcher(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (sheetContext) => const _CampusSwitcherSheet(),
  );
}

class _CampusSwitcherSheet extends StatelessWidget {
  const _CampusSwitcherSheet();

  @override
  Widget build(BuildContext context) {
    final data = AppDataScope.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Switch campus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...data.campuses.map((c) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: c.themeColor, child: Text(c.name.substring(0, 1), style: const TextStyle(color: Colors.white))),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                subtitle: Text(c.location, style: const TextStyle(fontSize: 11.5)),
                trailing: data.currentCampus.id == c.id ? Icon(Icons.check, color: c.themeColor) : null,
                onTap: () {
                  data.switchCampus(c);
                  Navigator.of(context).pop();
                },
              )),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.add_business_outlined),
            title: const Text('Add a new university (admin)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddUniversityScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class AddUniversityScreen extends StatefulWidget {
  const AddUniversityScreen({super.key});

  @override
  State<AddUniversityScreen> createState() => _AddUniversityScreenState();
}

class _AddUniversityScreenState extends State<AddUniversityScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  Color _color = const Color(0xFF2E86C1);

  static const _presetColors = [
    Color(0xFF2E86C1), Color(0xFF1E8449), Color(0xFF6C3483),
    Color(0xFFCA6F1E), Color(0xFFB03A2E), Color(0xFF117864),
  ];

  @override
  Widget build(BuildContext context) {
    final data = AppDataScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add university')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This creates a new campus marketplace, live immediately, with no app rebuild.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'University name')),
            const SizedBox(height: 12),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location (city, state)')),
            const SizedBox(height: 16),
            const Text('Theme color', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: _presetColors.map((c) {
                final selected = c.value == _color.value;
                return InkWell(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: c, shape: BoxShape.circle,
                      border: selected ? Border.all(color: Colors.black, width: 2) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nameController.text.trim().isEmpty && _locationController.text.trim().isEmpty
                    ? null
                    : () {
                        data.addCampus(
                          name: _nameController.text.trim().isEmpty ? 'New Campus' : _nameController.text.trim(),
                          location: _locationController.text.trim(),
                          color: _color,
                        );
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('University added and now active')));
                      },
                child: const Text('Create university marketplace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// Product detail
// =========================================================

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final data = AppDataScope.of(context);
    final accent = data.currentCampus.themeColor;
    final favorited = data.favoriteIds.contains(product.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Listing')),
      body: ListView(
        children: [
          Container(height: 180, color: accent.withOpacity(0.08), child: Icon(product.icon, size: 72, color: accent)),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(product.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('\u20a6${product.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: accent)),
                const SizedBox(height: 14),
                Text(product.description, style: const TextStyle(fontSize: 13.5, height: 1.5)),
                const SizedBox(height: 18),
                Text('Sold by ${product.seller}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Message sent to ${product.seller} (demo)')),
                ),
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text('Message'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  data.placeOrder(product);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to your orders')));
                  Navigator.of(context).pop();
                },
                child: const Text('Add to order'),
              ),
            ),
            IconButton(
              onPressed: () => data.toggleFavorite(product.id),
              icon: Icon(favorited ? Icons.favorite : Icons.favorite_border, color: accent),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// Sell (add listing)
// =========================================================

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'Electronics';

  static const _categories = ['Electronics', 'Fashion', 'Books', 'Health & Beauty', 'Food & Drinks', 'Home & Living'];

  @override
  Widget build(BuildContext context) {
    final data = AppDataScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('New listing')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('Posting to ${data.currentCampus.name}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
          const SizedBox(height: 14),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (\u20a6)')),
          const SizedBox(height: 12),
          TextField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text.trim();
              final price = double.tryParse(_priceController.text.trim()) ?? 0;
              if (title.isEmpty || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a title and a valid price first')));
                return;
              }
              data.addProduct(Product(
                id: 'p${DateTime.now().millisecondsSinceEpoch}',
                campusId: data.currentCampus.id,
                title: title,
                seller: 'You',
                price: price,
                category: _category,
                icon: Icons.inventory_2_outlined,
                description: _descController.text.trim().isEmpty ? 'No description provided.' : _descController.text.trim(),
              ));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing published')));
            },
            child: const Text('Publish listing'),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// Wanted
// =========================================================

class WantedScreen extends StatelessWidget {
  const WantedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = AppDataScope.of(context);
    final accent = data.currentCampus.themeColor;
    final posts = data.wantedForCurrentCampus();

    return Scaffold(
      appBar: AppBar(title: const Text('Wanted')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddWantedScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Post'),
      ),
      body: posts.isEmpty
          ? const Center(child: Text('No wanted posts yet on this campus.', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final w = posts[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E7EA)), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(Icons.campaign_outlined, color: accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('Budget ${w.budget} \u00b7 ${w.postedBy}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class AddWantedScreen extends StatefulWidget {
  const AddWantedScreen({super.key});

  @override
  State<AddWantedScreen> createState() => _AddWantedScreenState();
}

class _AddWantedScreenState extends State<AddWantedScreen> {
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final data = AppDataScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Post what you need')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'What are you looking for?')),
            const SizedBox(height: 12),
            TextField(controller: _budgetController, decoration: const InputDecoration(labelText: 'Budget (\u20a6)')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Describe what you need first')));
                  return;
                }
                data.addWantedPost(WantedPost(
                  id: 'w${DateTime.now().millisecondsSinceEpoch}',
                  campusId: data.currentCampus.id,
                  title: title,
                  budget: _budgetController.text.trim().isEmpty ? 'Open' : '\u20a6${_budgetController.text.trim()}',
                  postedBy: 'You',
                ));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wanted post published')));
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// Orders
// =========================================================

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = AppDataScope.of(context);
    final accent = data.currentCampus.themeColor;

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: data.orders.isEmpty
          ? const Center(child: Text('Your orders will appear here.', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final o = data.orders[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E7EA)), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(o.product.icon, color: accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.product.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            Text('\u20a6${o.product.price.toStringAsFixed(0)}', style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      Chip(label: Text(o.status, style: const TextStyle(fontSize: 11))),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// =========================================================
// Profile
// =========================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = AppDataScope.of(context);
    final accent = data.currentCampus.themeColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 26, backgroundColor: accent, child: const Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.currentUser?.email ?? 'Guest user', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(data.currentCampus.name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Switch campus'),
            onTap: () => showCampusSwitcher(context),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: Text('Favorites (${data.favoriteIds.length})'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.add_business_outlined),
            title: const Text('Add a new university (admin)'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddUniversityScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () => data.signOut(),
          ),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = AppDataScope.of(context);
    final favorites = data.products.where((p) => data.favoriteIds.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? const Center(child: Text('No favorites yet.', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = favorites[i];
                return ListTile(
                  leading: Icon(p.icon),
                  title: Text(p.title),
                  subtitle: Text('\u20a6${p.price.toStringAsFixed(0)}'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
                );
              },
            ),
    );
  }
}
