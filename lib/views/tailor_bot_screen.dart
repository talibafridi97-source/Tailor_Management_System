import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../controllers/order_provider.dart';

class TailorBotScreen extends StatefulWidget {
  const TailorBotScreen({super.key});

  @override
  State<TailorBotScreen> createState() => _TailorBotScreenState();
}

class _TailorBotScreenState extends State<TailorBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Assalam-o-Alaikum! Main aapka Tailor Bot hoon. Aap mujhse kisi bhi topic par baat kar sakte hain, ya dukan ke orders aur income ke baray mein pooch sakte hain!",
      isUser: false,
    ),
  ];
  bool _isLoading = false;

  static const String _geminiApiKey = 'AIzaSyD-YOUR-API-KEY-HERE'; 

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    try {
      final orders = context.read<OrderProvider>().orders;
      
      int totalOrders = orders.length;
      int pending = orders.where((o) => o['status']?.toString().toLowerCase() == 'pending').length;
      int complete = orders.where((o) => o['status']?.toString().toLowerCase() == 'complete').length;
      double totalRevenue = orders.fold(0.0, (sum, o) => sum + (double.tryParse(o['advancePayment']?.toString() ?? '0') ?? 0.0));

      String aiResponse = "";
      if (_geminiApiKey.contains('YOUR-API-KEY')) {
        await Future.delayed(const Duration(seconds: 1));
        final lower = text.toLowerCase();
        
        if (lower.contains('pending') || lower.contains('kitne') || lower.contains('orders') || lower.contains('order')) {
          aiResponse = "Aapke paas is waqt $pending pending orders hain (total $totalOrders orders mein se). ($complete orders complete ho chuke ہیں۔)";
        } else if (lower.contains('revenue') || lower.contains('income') || lower.contains('paisa') || lower.contains('kamai') || lower.contains('profit')) {
          aiResponse = "Aapki ab tak ki total collected revenue (advance payment) Rs. $totalRevenue hai.";
        } else if (lower.contains('kaise') || lower.contains('kaiso') || lower.contains('how are') || lower.contains('kese')) {
          aiResponse = "Main bilkul theek hoon Alhamdulillah! Aap batayein, aapki dukan ka kaam kaisa chal raha hai?";
        } else if (lower.contains('haha') || lower.contains('lol') || lower.contains('khoob') || lower.contains('hahah')) {
          aiResponse = "Haha! Sahi hai. Dukan ke sath sath thori khushi aur mazaq bhi zaroori hai. Batayein koi naya order note karna hai?";
        } else if (lower.contains('acha') || lower.contains('ok') || lower.contains('theek')) {
          aiResponse = "G bilkul! Agar aapko kisi order ya payment ke baray mein kuch pochna ho to main hamesha hazir hoon.";
        } else if (lower.contains('urdu') || lower.contains('saktay') || lower.contains('baat') || lower.contains('kya')) {
          aiResponse = "G bilkul! Main aap se Roman Urdu aur English dono mein bilkul aam taur par baat kar sakta hoon.";
        } else if (lower.contains('hello') || lower.contains('salam') || lower.contains('hi')) {
          aiResponse = "Walaikum Assalam! Main aapka Tailor Bot hoon. Aaj dukan par kya kya kaam hai?";
        } else {
          aiResponse = "Aapki baat samajh aa gayi! Aapki dukan mein filhal $totalOrders total orders hain ($pending pending). Aur bataiye, main aur kis tarah aapki madad karoon?";
        }
      } else {
        final contextPrompt = """
You are Tailor Bot, a smart AI shop assistant for a Tailor Management System. 
Store Live Data:
- Total Orders: $totalOrders
- Pending Orders: $pending
- Complete Orders: $complete
- Total Revenue Collected: Rs. $totalRevenue

Answer the shop owner's message naturally in the same language/tone they used (Urdu, Roman Urdu, or English). Be friendly, conversational, and helpful.
User's Message: $text
""";
        final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _geminiApiKey);
        final content = [Content.text(contextPrompt)];
        final response = await model.generateContent(content);
        aiResponse = response.text ?? "I'm sorry, I couldn't generate a response.";
      }

      setState(() {
        _messages.add(ChatMessage(text: aiResponse, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Error: $e", isUser: false));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.amber),
            SizedBox(width: 10),
            Text("Tailor Bot (AI Assistant)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.amber.shade50,
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, size: 20, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(child: Text("Chat with me in Urdu or English about anything or store stats!", style: TextStyle(fontSize: 12, color: Colors.brown))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg.isUser ? const Color(0xFF0056D2) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(color: msg.isUser ? Colors.white : Colors.black87, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type message in Urdu or English...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF1A1A2E),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}
