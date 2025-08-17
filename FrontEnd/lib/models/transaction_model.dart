class Transaction {
  final int userId;
  final int orderId;
  final double amount;
  final String createdAt;
  final String userName;

  Transaction({
    required this.userId,
    required this.orderId,
    required this.amount,
    required this.createdAt,
    required this.userName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      userId: json['userId'],
      orderId: json['orderId'],
      amount: (json['amount'] as num).toDouble(),
      createdAt: json['createdAt'],
      userName: json['userName'],
    );
  }
} 