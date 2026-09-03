import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'create_order_screen.dart';
import 'order_detail_screen.dart';
import 'dashboard_screen.dart';
import 'customer_screen.dart';
import 'inventory_screen.dart';
import 'due_payment_screen.dart';
import 'settings_screen.dart';
import '../core/app_translations.dart';
import '../controllers/settings_controller.dart';
import '../controllers/order_provider.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

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
    // TODO: Implement actual logout
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
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0056D2), Color(0xFF4A90E2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 35),
              ),
              accountName: Text(t('app_title'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: const Text("tailor@management.com", style: TextStyle(color: Colors.white70, fontSize: 13)),
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
      leading: Container(
        padding: const EdgeInsets.all(8), 
        decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), 
        child: Icon(icon, color: iconColor, size: 20)
      ),
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<OrderProvider>().fetchOrders(),
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
      body: RefreshIndicator(
        onRefresh: () => context.read<OrderProvider>().fetchOrders(),
        child: Column(
          children: [
            _buildQuickStats(),
            if (_showSearchBar)
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF1A1A2E),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search customer name...",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
              ),
            Expanded(child: _buildOrderList()),
          ],
        ),
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

  Widget _buildQuickStats() {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem("Total Orders", provider.orders.length.toString(), Colors.blue),
              _statItem("Pending", provider.pendingCount.toString(), Colors.orange),
              _statItem("Baqaya", "Rs. ${provider.totalDueAmount.toInt()}", Colors.red),
            ],
          ),
        );
      }
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildOrderList() {
    final settings = Provider.of<SettingsController>(context, listen: false);
    final locale = settings.locale.languageCode;
    String t(String key) => AppTranslations.getText(key, locale);

    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null && provider.orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 10),
                  Text(provider.errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: () => provider.fetchOrders(), child: const Text("Retry")),
                ],
              ),
            ),
          );
        }

        var filteredOrders = provider.orders.where((o) {
           final s = o['status']?.toString().toLowerCase() ?? 'pending';
           return s == _statusFilter;
        }).toList();

        if (_searchQuery.isNotEmpty) {
          filteredOrders = filteredOrders.where((o) => 
            (o['clientName'] ?? '').toString().toLowerCase().contains(_searchQuery)
          ).toList();
        }

        if (filteredOrders.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("No $_statusFilter orders found", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => provider.fetchOrders(),
                    child: const Text("Try Refreshing"),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final data = filteredOrders[index];
            final id = data['_id'] ?? data['id'] ?? ''; 
            double due = double.tryParse(data['dueAmount']?.toString() ?? '0') ?? 0.0;
            bool isPinned = data['isPinned'] ?? false;

            return _orderCard(data, id, due, isPinned, t, provider);
          },
        );
      },
    );
  }

  Widget _orderCard(Map<String, dynamic> data, String id, double due, bool isPinned, String Function(String) t, OrderProvider provider) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String status = data['status']?.toString().toLowerCase() ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isPinned ? Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5) : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: data, orderId: id))),
            leading: CircleAvatar(
              backgroundColor: _statusColor.withOpacity(0.1),
              child: Icon(Icons.person, color: _statusColor),
            ),
            title: Text(data['clientName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(data['garment'] ?? ''),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (due > 0) Text("Rs. ${due.toInt()}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                if (isPinned) const Icon(Icons.push_pin, color: Colors.redAccent, size: 16),
              ],
            ),
          ),
          if (status != 'delivered')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus(id, status == 'pending' ? 'complete' : 'delivered', provider),
                    icon: Icon(
                      status == 'pending' ? Icons.check_circle : Icons.local_shipping,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      status == 'pending' ? "Mark Complete" : "Mark Delivered",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == 'pending' ? Colors.green : Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _updateStatus(String id, String newStatus, OrderProvider provider) async {
    final success = await provider.updateStatus(id, newStatus);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order moved to $newStatus"), backgroundColor: Colors.green),
      );
    }
  }
}
