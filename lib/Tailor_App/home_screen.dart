import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_order_screen.dart';
import 'order_detail_screen.dart';
import 'dashboard_screen.dart';
import 'customer_screen.dart';
import 'inventory_screen.dart';
import 'due_payment_screen.dart';
import 'settings_screen.dart';
import 'app_translations.dart';
import 'settings_provider.dart';
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
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text("Logout failed: $e")),
        );
      }
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final settings = Provider.of<SettingsProvider>(context);
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
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
              builder: (context, snapshot) {
                String name = t('app_title');
                String email = user?.email ?? "";
                String profilePic = "";

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  name = data['name'] ?? name;
                  profilePic = data['profilePic'] ?? "";
                }

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0056D2), Color(0xFF4A90E2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  currentAccountPicture: GestureDetector(
                    onTap: () => _showProfileDialog(context, name, profilePic),
                    child: CircleAvatar(
                      backgroundColor: Colors.white24,
                      backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                      child: profilePic.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 35) : null,
                    ),
                  ),
                  accountName: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  accountEmail: Text(email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                );
              },
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final settings = Provider.of<SettingsProvider>(context);
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
          Expanded(child: _buildOrderList(user.uid)),
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
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final locale = settings.locale.languageCode;
    String t(String key) => AppTranslations.getText(key, locale);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: uid).where('status', isEqualTo: _statusFilter).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        var orders = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? []);

        // Manual Sorting: Pinned orders first, then by timestamp
        orders.sort((a, b) {
          final da = a.data() as Map<String, dynamic>;
          final db = b.data() as Map<String, dynamic>;
          bool pinA = da['isPinned'] ?? false;
          bool pinB = db['isPinned'] ?? false;
          
          if (pinA != pinB) return pinB ? 1 : -1;
          
          final ta = da['timestamp'] as Timestamp?;
          final tb = db['timestamp'] as Timestamp?;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });

        if (_searchQuery.isNotEmpty) {
          orders = orders.where((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return (d['clientName'] ?? '').toString().toLowerCase().contains(_searchQuery) ||
                   (d['phone'] ?? '').toString().contains(_searchQuery);
          }).toList();
        }

        if (orders.isEmpty) {
          String statusText = t(_statusFilter);
          return Center(child: Text("No $statusText orders found", style: const TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final data = orders[index].data() as Map<String, dynamic>;
            final id = orders[index].id;
            double due = 0;
            if (data['dueAmount'] != null) {
              due = double.tryParse(data['dueAmount'].toString()) ?? 0.0;
            }

            bool isDark = Theme.of(context).brightness == Brightness.dark;
            bool isPinned = data['isPinned'] ?? false;

            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: data, orderId: id))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: isPinned ? Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5) : null,
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: isPinned ? Colors.redAccent.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 6,
                        child: Container(color: isPinned ? Colors.redAccent : _statusColor),
                      ),
                      if (isPinned)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Icon(Icons.push_pin, color: Colors.redAccent.withOpacity(0.8), size: 18),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (isPinned ? Colors.redAccent : _statusColor).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                data['garment']?.toString().toLowerCase().contains('suit') ?? false
                                    ? Icons.checkroom
                                    : Icons.person,
                                color: isPinned ? Colors.redAccent : _statusColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        data['clientName'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 17,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      if (isPinned)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(6)),
                                          child: Text(t('urgent').toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.style, size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Text(
                                        data['garment'] ?? '',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.phone, size: 12, color: Colors.grey.shade400),
                                      const SizedBox(width: 4),
                                      Text(
                                        data['phone'] ?? '',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (due > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Baqaya",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Rs. ${due.toInt()}",
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, color: Colors.green, size: 20),
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        FirebaseFirestore.instance.collection('orders').doc(id).update({
                                          'isPinned': !isPinned
                                        });
                                      },
                                      child: Icon(
                                        isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                        color: isPinned ? Colors.redAccent : Colors.grey.withOpacity(0.5),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    InkWell(
                                      onTap: () => _deleteOrderDialog(id),
                                      child: Icon(Icons.delete_outline, color: Colors.red.withOpacity(0.5), size: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }



  void _showProfileDialog(BuildContext context, String currentName, String currentPic) {
    final nameController = TextEditingController(text: currentName);
    final picController = TextEditingController(text: currentPic);
    final user = FirebaseAuth.instance.currentUser;

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
              if (user != null) {
                await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                  'name': nameController.text.trim(),
                  'profilePic': picController.text.trim(),
                });
                if (context.mounted) Navigator.pop(ctx);
              }
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
              await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
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
