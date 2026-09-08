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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<OrderProvider>().fetchOrders(),
          )
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Group orders by Karigar
          Map<String, List<dynamic>> karigarMap = {};
          
          for (var o in provider.orders) {
            String name = (o['karigarName'] ?? '').toString().trim();
            if (name.isEmpty) name = 'Unassigned (No Worker)';
            
            if (!karigarMap.containsKey(name)) {
              karigarMap[name] = [];
            }
            karigarMap[name]!.add(o);
          }

          if (provider.orders.isEmpty) {
            return const Center(child: Text("No orders found in the system."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: karigarMap.length,
            itemBuilder: (context, index) {
              String name = karigarMap.keys.elementAt(index);
              List<dynamic> workerOrders = karigarMap[name]!;
              
              int pending = workerOrders.where((o) => o['status'] == 'pending').length;
              int ready = workerOrders.where((o) => o['status'] == 'complete').length;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: name.contains('Unassigned') ? Colors.grey.shade200 : Colors.blue.shade50,
                            child: Icon(Icons.person, color: name.contains('Unassigned') ? Colors.grey : Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statCol("Pending", pending, Colors.orange),
                          _statCol("Ready", ready, Colors.green),
                          _statCol("Total", workerOrders.length, Colors.purple),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statCol(String label, int val, Color color) {
    return Column(
      children: [
        Text("$val", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
