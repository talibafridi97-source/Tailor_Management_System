import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_order_screen.dart';
import 'order_detail_screen.dart';
import 'dashboard_screen.dart';
import 'customer_screen.dart';
import 'inventory_screen.dart';
import 'due_payment_screen.dart';

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
                String name = "Tailor Book";
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
            _drawerItem(Icons.home, "Home", Colors.cyanAccent, () {}),
            _drawerItem(Icons.add_shopping_cart, "Create Order", Colors.orangeAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateOrderScreen()));
            }),
            _drawerItem(Icons.dashboard, "Dashboard", Colors.yellowAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
            }),
            _drawerItem(Icons.payment, "Due Payment", Colors.redAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DuePaymentScreen()));
            }),
            _drawerItem(Icons.people, "Customers", Colors.greenAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerScreen()));
            }),
            _drawerItem(Icons.inventory, "Inventory", Colors.purpleAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
            }),
            const Divider(color: Colors.white24),
            _drawerItem(Icons.logout, "Logout", Colors.redAccent, () => _logout(context)),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
        title: const Text("Tailor Book", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pending_actions), label: 'Pending'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Complete'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Delivered'),
        ],
      ),
    );
  }

  Widget _buildOrderList(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: uid).where('status', isEqualTo: _statusFilter).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        var orders = snapshot.data?.docs ?? [];
        if (_searchQuery.isNotEmpty) {
          orders = orders.where((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return (d['clientName'] ?? '').toString().toLowerCase().contains(_searchQuery) ||
                   (d['phone'] ?? '').toString().contains(_searchQuery);
          }).toList();
        }

        if (orders.isEmpty) {
          return Center(child: Text("No $_statusFilter orders found", style: const TextStyle(color: Colors.grey)));
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

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: ListTile(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: data, orderId: id))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(backgroundColor: _statusColor.withOpacity(0.1), child: Icon(Icons.person, color: _statusColor)),
                title: Text(data['clientName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['garment'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (due > 0) ...[
                          const Text("Baqaya", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text("Rs. $due", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 14)),
                        ] else
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                      onPressed: () => _deleteOrderDialog(id),
                    ),
                  ],
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
