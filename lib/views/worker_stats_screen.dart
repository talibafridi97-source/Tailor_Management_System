import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/order_provider.dart';

class WorkerStatsScreen extends StatelessWidget {
  const WorkerStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]))),
        title: const Text("Karigar Workload", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());

          // Logic to group orders by Karigar
          Map<String, List<dynamic>> karigarMap = {};
          for (var o in provider.orders) {
            String name = o['karigarName'] ?? 'Unassigned';
            if (name.isEmpty) name = 'Unassigned';
            if (!karigarMap.containsKey(name)) karigarMap[name] = [];
            karigarMap[name]!.add(o);
          }

          if (karigarMap.isEmpty) return const Center(child: Text("No workers assigned yet"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: karigarMap.length,
            itemBuilder: (context, index) {
              String name = karigarMap.keys.elementAt(index);
              List<dynamic> workerOrders = karigarMap[name]!;
              int pending = workerOrders.where((o) => o['status'] == 'pending').length;
              int complete = workerOrders.where((o) => o['status'] == 'complete').length;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(backgroundColor: Colors.blue.withOpacity(0.1), child: const Icon(Icons.engineering, color: Colors.blue)),
                        const SizedBox(width: 12),
                        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _miniCount("Pending", pending, Colors.orange),
                        _miniCount("Completed", complete, Colors.green),
                        _miniCount("Total", workerOrders.length, Colors.purple),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _miniCount(String label, int count, Color color) {
    return Column(
      children: [
        Text("$count", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
