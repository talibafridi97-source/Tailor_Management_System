import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // TODO: Replace with MongoDB equivalent
// import 'package:firebase_auth/firebase_auth.dart'; // TODO: Replace with MongoDB Auth
import 'create_order_screen.dart';
import 'order_detail_screen.dart';
import 'dashboard_screen.dart';
import 'customer_screen.dart';
import 'inventory_screen.dart';
import 'due_payment_screen.dart';
import 'settings_screen.dart';
import '../core/app_translations.dart';
import '../controllers/settings_controller.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _statusFilter {
    switch (_selectedIndex) {
      case 0: return 'pending';
      case 1: return 'complete';
      case 2: return 'delivered';
      default: return 'pending';
    }
  }

  Color get _statusColor {
    switch (_selectedIndex) {
      case 0: return const Color(0xFFFF8C00);
      case 1: return const Color(0xFF00C853);
      case 2: return const Color(0xFF2979FF);
      default: return const Color(0xFFFF8C00);
    }
  }

  Future<void> _logout(BuildContext ctx) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // TODO: Implement MongoDB Logout logic
      if (ctx.mounted) {
         Navigator.of(ctx).pushReplacementNamed('/login'); // Assuming a login route exists
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text("Logout failed: $e")),
        );
      }
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);
    final locale = settings.locale.languageCode;
    String t(String key) => AppTranslations.getText(key, locale);

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // TODO: Replace with MongoDB User Data fetch
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0056D2), Color(0xFF4A90E2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: GestureDetector(
                onTap: () => _showProfileDialog(context, t('app_title'), ""),
                child: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 35),
                ),
              ),
              accountName: Text(t('app_title'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: const Text("user@example.com", style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
            _drawerItem(Icons.home, t('home'), Colors.cyanAccent, () {}),
            _drawerItem(Icons.add_shopping_cart, t('create_order'), Colors.orangeAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateOrderScreen()));
            }),
            _drawerItem(Icons.dashboard, t('dashboard'), Colors.yellowAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
            }),
            _drawerItem(Icons.payment, t('due_payment'), Colors.redAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DuePaymentScreen()));
            }),
            _drawerItem(Icons.people, t('customers'), Colors.greenAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerScreen()));
            }),
            _drawerItem(Icons.inventory, t('inventory'), Colors.purpleAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
            }),
            _drawerItem(Icons.settings, t('settings'), Colors.blueGrey, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }),
            const Divider(color: Colors.white24),
            _drawerItem(Icons.logout, t('logout'), Colors.redAccent, () => _logout(context)),
          ],
        ),
      ),
    );
  }


  Widget _drawerItem(IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      onTap: () { Navigator.pop(context); onTap(); },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);
    final locale = settings.locale.languageCode;
    String t(String key) => AppTranslations.getText(key, locale);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)]))),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(t('app_title'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Notification action
            },
          ),
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () => setState(() {
              _showSearchBar = !_showSearchBar;
              if (!_showSearchBar) { _searchController.clear(); _searchQuery = ''; }
            }),
          )
        ],
      ),
      body: Column(
        children: [
          if (_showSearchBar)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1A1A2E),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search customer name or phone...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
            ),
          Expanded(child: _buildOrderList("current_user_id")),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateOrderScreen())),
        backgroundColor: const Color(0xFF0056D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF0056D2),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.pending_actions), label: t('pending')),
          BottomNavigationBarItem(icon: const Icon(Icons.check_circle), label: t('complete')),
          BottomNavigationBarItem(icon: const Icon(Icons.local_shipping), label: t('delivered')),
        ],
      ),
    );
  }

  Widget _buildOrderList(String uid) {
    // TODO: Replace with MongoDB data fetch
    return const Center(child: Text("TODO: Connect MongoDB Order Stream", style: TextStyle(color: Colors.grey)));
  }

  void _showProfileDialog(BuildContext context, String currentName, String currentPic) {
    final nameController = TextEditingController(text: currentName);
    final picController = TextEditingController(text: currentPic);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: picController,
                decoration: const InputDecoration(labelText: "Profile Image URL", prefixIcon: Icon(Icons.image), hintText: "https://..."),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              // TODO: Implement MongoDB Profile update
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056D2), foregroundColor: Colors.white),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteOrderDialog(String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Order?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this order record permanently?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              // TODO: Implement MongoDB Delete logic
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
