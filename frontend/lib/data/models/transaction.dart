class PaymentTransaction {
  final int txnId;
  final double totalAmount;
  final String txnStatus;
  final String paymentMode;

  PaymentTransaction({
    required this.txnId,
    required this.totalAmount,
    required this.txnStatus,
    required this.paymentMode,
  });

  Map<String, dynamic> toJson() {
    return {
      'txn_id': txnId,
      'total_amount': totalAmount,
      'txn_status': txnStatus,
      'payment_mode': paymentMode,
    };
  }

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      txnId: json['txn_id'],
      totalAmount: json['total_amount'],
      txnStatus: json['txn_status'],
      paymentMode: json['payment_mode'],
    );
  }
}

class CreateTransaction {
  final double totalAmount;
  final String txnStatus;
  final String paymentMode;

  CreateTransaction({
    required this.totalAmount,
    required this.txnStatus,
    required this.paymentMode,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_amount': totalAmount,
      'txn_status': txnStatus,
      'payment_mode': paymentMode,
    };
  }

  factory CreateTransaction.fromJson(Map<String, dynamic> json) {
    return CreateTransaction(
      totalAmount: json['total_amount'],
      txnStatus: json['txn_status'],
      paymentMode: json['payment_mode'],
    );
  }
}

