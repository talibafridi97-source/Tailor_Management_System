import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/order_provider.dart';

class WorkerStatsScreen extends StatefulWidget {
  const WorkerStatsScreen({super.key});

  @override
  State<WorkerStatsScreen> createState() => _WorkerStatsScreenState();
}

class _WorkerStatsScreenState extends State<WorkerStatsScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure orders are loaded when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
          ),
        ),
        title: const Text("Staff Workload Tracking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Logic to group orders by Karigar (Worker)
          Map<String, List<dynamic>> karigarMap = {};
          
          for (var o in provider.orders) {
            // Check both possible keys from backend
            String name = (o['karigarName'] ?? o['workerName'] ?? 'Unassigned').toString();
            if (name.trim().isEmpty) name = 'Unassigned';
            
            if (!karigarMap.containsKey(name)) {
              karigarMap[name] = [];
            }
            karigarMap[name]!.add(o);
          }

          if (karigarMap.isEmpty || (karigarMap.length == 1 && karigarMap.containsKey('Unassigned') && karigarMap['Unassigned']!.isEmpty)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.engineering_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("No orders found to track staff workload.", style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () => provider.fetchOrders(),
                    child: const Text("Refresh Data"),
                  )
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: karigarMap.length,
              itemBuilder: (context, index) {
                String name = karigarMap.keys.elementAt(index);
                List<dynamic> workerOrders = karigarMap[name]!;
                
                int pending = workerOrders.where((o) => 
                  o['status']?.toString().toLowerCase() == 'pending'
                ).length;
                
                int complete = workerOrders.where((o) => 
                  o['status']?.toString().toLowerCase() == 'complete'
                ).length;

                int delivered = workerOrders.where((o) => 
                  o['status']?.toString().toLowerCase() == 'delivered'
                ).length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.person, color: Colors.blue, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _miniStat("Pending", pending, Colors.orange),
                          _miniStat("Ready", complete, Colors.green),
                          _miniStat("Delivered", delivered, Colors.blue),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _miniStat(String label, int val, Color color) {
    return Column(
      children: [
        Text("$val", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
