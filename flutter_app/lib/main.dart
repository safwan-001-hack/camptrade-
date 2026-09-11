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
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF8EC9E8)),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int tab = 0;
  final pages = const [MarketPage(), WantedPage(), OrdersPage(), ProfilePage()];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('CampTrade', style: TextStyle(fontWeight: FontWeight.bold)),
      bottom: const PreferredSize(preferredSize: Size.fromHeight(25),
        child: Align(alignment: Alignment.centerLeft, child: Padding(
          padding: EdgeInsets.only(left:16,bottom:8), child: Text('Federal University of Technology, Minna')))),
    ),
    body: pages[tab],
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab, onDestinationSelected: (v)=>setState(()=>tab=v),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.storefront_outlined), label:'Market'),
        NavigationDestination(icon: Icon(Icons.campaign_outlined), label:'Wanted'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label:'Orders'),
        NavigationDestination(icon: Icon(Icons.person_outline), label:'Profile'),
      ]),
  );
}

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});
  @override
  Widget build(BuildContext context) {
    final items=[('HP Laptop','₦280,000',Icons.laptop_mac),('Campus Sneakers','₦25,000',Icons.shopping_bag),('Textbooks','₦12,000',Icons.menu_book),('Bluetooth Speaker','₦18,500',Icons.speaker)];
    return ListView(padding: const EdgeInsets.all(16), children:[
      TextField(decoration: InputDecoration(hintText:'Search products...',prefixIcon:const Icon(Icons.search),filled:true,border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide.none))),
      const SizedBox(height:16),
      Row(children:[
        Expanded(child:FilledButton.icon(onPressed:()=>_msg(context,'Sell'),icon:const Icon(Icons.add),label:const Text('Sell'))),
        const SizedBox(width:10),
        Expanded(child:OutlinedButton.icon(onPressed:()=>_msg(context,'Wanted'),icon:const Icon(Icons.campaign),label:const Text('Wanted')))]),
      const SizedBox(height:20),
      const Text('Marketplace',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
      ...items.map((i)=>Card(child:ListTile(leading:CircleAvatar(child:Icon(i.$3)),title:Text(i.$1),subtitle:const Text('Verified campus seller'),trailing:Text(i.$2,style:const TextStyle(fontWeight:FontWeight.bold)))))
    ]);
  }
  static void _msg(BuildContext c,String s)=>ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('$s feature is ready for backend connection.')));
}
class WantedPage extends StatelessWidget {
  const WantedPage({super.key});
  @override Widget build(BuildContext c)=>Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const Icon(Icons.campaign_outlined,size:64),const SizedBox(height:12),
    const Text('Wanted Items',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
    const SizedBox(height:8),const Text('Post what you need and let campus sellers find you.'),
    const SizedBox(height:18),FilledButton(onPressed:(){},child:const Text('Create Wanted Post'))
  ]));
}
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override Widget build(BuildContext c)=>const Center(child:Text('Your orders will appear here.'));
}
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override Widget build(BuildContext c)=>const ListView(padding:EdgeInsets.all(20),children:[
    CircleAvatar(radius:40,child:Icon(Icons.person,size:44)),SizedBox(height:12),
    Center(child:Text('Campus Student',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold))),
    Center(child:Text('FUT Minna • Student verification')),SizedBox(height:20),
    Card(child:ListTile(leading:Icon(Icons.verified_outlined),title:Text('Student Verification'),subtitle:Text('Connect verification to Supabase.'))),
    Card(child:ListTile(leading:Icon(Icons.security_outlined),title:Text('Security'),subtitle:Text('Protected by Supabase authentication.')))
  ]);
}
