// ignore_for_file: constant_identifier_names

enum SeatType {
  SL,
  SU,
  LL,
  MD,
  UP,
  ST,
  FC,
}

enum SeatCategory {
  CNF,
  RAC,
}

Map<SeatType, String> seatTypeToString = {
  SeatType.SL: "SL",
  SeatType.SU: "SU",
  SeatType.LL: "LL",
  SeatType.MD: "MD",
  SeatType.UP: "UP",
  SeatType.ST: "ST",
  SeatType.FC: "FC",
};

Map<SeatCategory, String> seatCategoryToString = {
  SeatCategory.CNF: "CNF",
  SeatCategory.RAC: "RAC",
};

class SeatResponse {
  final int seatId;
  final int seatNo;
  final String seatType;
  final int coachId;
  final String seatCategory;

  SeatResponse({
    required this.seatId,
    required this.seatNo,
    required this.seatType,
    required this.coachId,
    required this.seatCategory,
  });

  factory SeatResponse.fromJson(Map<String, dynamic> json) {
    return SeatResponse(
      seatId: json['seat_id'],
      seatNo: json['seat_no'],
      seatType: json['seat_type'],
      coachId: json['coach_id'],
      seatCategory: json['seat_category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seat_id': seatId,
      'seat_no': seatNo,
      'seat_type': seatType,
      'coach_id': coachId,
      'seat_category': seatCategory,
    };
  }
}

class CreateSeat {
  final int seatNo;
  final String seatType; // Enum string like "LL", "SU", etc.
  final int coachId;
  final String seatCategory; // "CNF" or "RAC"

  CreateSeat({
    required this.seatNo,
    required this.seatType,
    required this.coachId,
    required this.seatCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'seat_no': seatNo,
      'seat_type': seatType,
      'coach_id': coachId,
      'seat_category': seatCategory,
    };
  }
}

class SeatCount {
  final String reservationCategory;
  final int seatCount;

  SeatCount({
    required this.reservationCategory,
    required this.seatCount,
  });

  factory SeatCount.fromJson(Map<String, dynamic> json) {
    return SeatCount(
      reservationCategory: json['reservation_category'] as String,
      seatCount: json['seat_count'] as int,
    );
  }
}

