import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (url.isNotEmpty && key.isNotEmpty) {
    await Supabase.initialize(url: url, anonKey: key);
  }
  runApp(const CampTradeApp());
}

class CampTradeApp extends StatelessWidget {
  const CampTradeApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'CampTrade',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8DB9D9)),
    ),
    home: const CampTradeHome(),
  );
}

class CampTradeHome extends StatefulWidget {
  const CampTradeHome({super.key});
  @override State<CampTradeHome> createState() => _CampTradeHomeState();
}

class _CampTradeHomeState extends State<CampTradeHome> {
  int tab = 0;
  final items = const [
    ['Laptop', '₦250,000', Icons.laptop_mac],
    ['Sneakers', '₦35,000', Icons.directions_run],
    ['Textbooks', '₦12,000', Icons.menu_book],
    ['Backpack', '₦18,000', Icons.backpack],
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [_market(), _wanted(), _orders(), _profile()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampTrade', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: pages[tab],
      floatingActionButton: tab < 2 ? FloatingActionButton.extended(
        onPressed: () => _message(tab == 0 ? 'Create listing' : 'Post wanted item'),
        icon: const Icon(Icons.add), label: Text(tab == 0 ? 'Sell' : 'Wanted'),
      ) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), label: 'Wanted'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _market() => ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.school)),
      title: const Text('Federal University of Technology, Minna'),
      subtitle: const Text('Campus marketplace'),
      trailing: const Icon(Icons.chevron_right),
    )),
    const SizedBox(height: 18),
    const Text('Browse campus', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    Wrap(spacing: 8, children: ['Electronics','Fashion','Books','Food','Services']
      .map((x) => Chip(label: Text(x))).toList()),
    const SizedBox(height: 18),
    GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .82),
      itemBuilder: (_, i) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFDCEEF8), borderRadius: BorderRadius.circular(14)),
            child: Icon(items[i][2] as IconData, size: 52))),
          const SizedBox(height: 8),
          Text(items[i][0] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(items[i][1] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
        ]))),
    ),
  ]);

  Widget _wanted() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Wanted', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    const Text('Students can post what they need and sellers can respond.'),
    const SizedBox(height: 14),
    const Card(child: ListTile(
      leading: CircleAvatar(child: Icon(Icons.search)),
      title: Text('Looking for a used iPhone 12'),
      subtitle: Text('Budget: ₦280,000 • FUT Minna'),
    )),
    const Card(child: ListTile(
      leading: CircleAvatar(child: Icon(Icons.book)),
      title: Text('Need CSC textbook'),
      subtitle: Text('Budget: ₦8,000 • Bosso Campus'),
    )),
  ]);

  Widget _orders() => const Center(child: Text('Your orders will appear here.'));
  Widget _profile() => ListView(padding: const EdgeInsets.all(16), children: const [
    CircleAvatar(radius: 42, child: Icon(Icons.person, size: 44)),
    SizedBox(height: 14),
    Center(child: Text('Campus Student', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold))),
    Center(child: Text('FUT Minna')),
    SizedBox(height: 24),
    Card(child: ListTile(leading: Icon(Icons.verified_user_outlined),
      title: Text('Student verification'), subtitle: Text('Verify with student ID'))),
    Card(child: ListTile(leading: Icon(Icons.favorite_border), title: Text('Saved items'))),
    Card(child: ListTile(leading: Icon(Icons.settings_outlined), title: Text('Settings'))),
  ]);

  void _message(String title) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: const Text('This screen is ready to be connected to the CampTrade Supabase backend.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ),
  );
}
