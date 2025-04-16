class BookingDetail {
  final int pnr;
  final String passName;
  final int age;
  final String sex;
  final bool disability;
  final int bookingId;
  final String bookingTime;
  final String bookingStatus;
  final double amount;
  final int? txnId;
  final String? paymentMode;
  final String? txnStatus;
  final String? reservationStatus;
  final String? reservationCategory;
  final int? seatNo;
  final String? seatType;
  final String? seatCategory;
  final String? coachName;
  final String? coachType;
  final String? trainName;
  final String? trainType;
  final int journeyId;
  final DateTime startTime;
  final DateTime endTime;
  final String? startStation;
  final String? endStation;

  BookingDetail({
    required this.pnr,
    required this.passName,
    required this.age,
    required this.sex,
    required this.disability,
    required this.bookingId,
    required this.bookingTime,
    required this.bookingStatus,
    required this.amount,
    this.txnId,
    this.paymentMode,
    this.txnStatus,
    this.reservationStatus,
    this.reservationCategory,
    this.seatNo,
    this.seatType,
    this.seatCategory,
    this.coachName,
    this.coachType,
    this.trainName,
    this.trainType,
    required this.journeyId,
    required this.startTime,
    required this.endTime,
    this.startStation,
    this.endStation,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) => BookingDetail(
    pnr: json['pnr'],
    passName: json['pass_name'],
    age: json['age'],
    sex: json['sex'],
    disability: json['disability'] == 1,
    bookingId: json['booking_id'],
    bookingTime: json['booking_time'],
    bookingStatus: json['booking_status'],
    amount: (json['amount'] as num).toDouble(),
    txnId: json['txn_id'],
    paymentMode: json['payment_mode'],
    txnStatus: json['txn_status'],
    reservationStatus: json['reservation_status'],
    reservationCategory: json['reservation_category'],
    seatNo: json['seat_no'],
    seatType: json['seat_type'],
    seatCategory: json['seat_category'],
    coachName: json['coach_name'],
    coachType: json['coach_type'],
    trainName: json['train_name'],
    trainType: json['train_type'],
    journeyId: json['journey_id'],
    startTime: DateTime.parse(json['start_time']),
    endTime: DateTime.parse(json['end_time']),
    startStation: json['start_station'],
    endStation: json['end_station'],
  );
}


class CancelBookingRequest {
  final int bookingId;
  final double refundAmount;
  final int txnId;

  CancelBookingRequest({
    required this.bookingId,
    required this.refundAmount,
    required this.txnId,
  });

  Map<String, dynamic> toJson() => {
        'booking_id': bookingId,
        'refund_amount': refundAmount,
        'txn_id': txnId,
      };
}
