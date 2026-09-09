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
        title: const Text("Staff Performance Tracking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

          // Logic to group orders by Karigar
          Map<String, List<dynamic>> karigarMap = {};
          
          for (var o in provider.orders) {
            String name = (o['karigarName'] ?? '').toString().trim();
            
            // Clean up: If it's Karigar 1 or empty, mark as needs assignment
            if (name.isEmpty || name == "Karigar 1") {
              name = 'Pending Assignment (No Worker)';
            }
            
            if (!karigarMap.containsKey(name)) {
              karigarMap[name] = [];
            }
            karigarMap[name]!.add(o);
          }

          if (provider.orders.isEmpty) {
            return const Center(child: Text("No data available."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: karigarMap.length,
            itemBuilder: (context, index) {
              String name = karigarMap.keys.elementAt(index);
              List<dynamic> workerOrders = karigarMap[name]!;
              
              bool isPendingGroup = name.contains('Pending Assignment');
              
              int pending = workerOrders.where((o) => o['status'] == 'pending').length;
              int ready = workerOrders.where((o) => o['status'] == 'complete').length;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: isPendingGroup 
                    ? BorderSide(color: Colors.orange.shade200, width: 1) 
                    : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isPendingGroup ? Colors.orange.shade50 : Colors.blue.shade50,
                            child: Icon(
                              isPendingGroup ? Icons.warning_amber_rounded : Icons.person_outline, 
                              color: isPendingGroup ? Colors.orange : Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              name, 
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                color: isPendingGroup ? Colors.orange.shade900 : Colors.black87,
                              )
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 30, thickness: 0.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statCol("Active Orders", pending, Colors.orange),
                          _statCol("Ready Suits", ready, Colors.green),
                          _statCol("Total Work", workerOrders.length, Colors.blueGrey),
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
        Text("$val", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
