class ExpenseModel {
  final String? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  ExpenseModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['_id'],
      title: json['title'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      category: json['category'] ?? 'General',
      date: DateTime.parse(json['date']),
    );
  }
}
