class CreatePassenger {
  final String name;
  final int age;
  final String gender;
  final bool isDisabled;
  final double? fare;

  CreatePassenger({
    required this.name,
    required this.age,
    required this.gender,
    required this.isDisabled,
    this.fare,
  });
}

class Passenger {
  final String name;
  final int age;
  final String sex;
  final bool disability;
  final double fare;

  Passenger({
    required this.name,
    required this.age,
    required this.sex,
    required this.disability,
    required this.fare,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'sex': (sex[0].toUpperCase()),
        'disability': disability?1: 0,
        'fare': fare,
      };
}

class GroupBookingRequest {
  final int groupSize;
  final List<Passenger> passengerData;
  final int journeyId;
  final int trainId;
  final int startStationId;
  final int endStationId;
  final String mode;
  final int txnId;
  final String email;
  final String reservationCategory;

  GroupBookingRequest({
    required this.groupSize,
    required this.passengerData,
    required this.journeyId,
    required this.trainId,
    required this.startStationId,
    required this.endStationId,
    required this.mode,
    required this.txnId,
    required this.email,
    required this.reservationCategory,
  });

  Map<String, dynamic> toJson() => {
        'group_size': groupSize,
        'passenger_data': passengerData.map((p) => p.toJson()).toList(),
        'journey_id': journeyId,
        'train_id': trainId,
        'start_station_id': startStationId,
        'end_station_id': endStationId,
        'mode': mode,
        'txn_id': txnId,
        'email': email,
        'reservation_category': reservationCategory,
      };
}

class PnrStatus {
  final String trainName;
  final String startStation;
  final String endStation;
  final String coachName;
  final int seatNo;
  final String seatType;
  final String bookingStatus;
  final String startTime;
  final String endTime;

  PnrStatus({
    required this.trainName,
    required this.startStation,
    required this.endStation,
    required this.coachName,
    required this.seatNo,
    required this.seatType,
    required this.bookingStatus,
    required this.startTime,
    required this.endTime,
  });

  factory PnrStatus.fromJson(Map<String, dynamic> json) {
    return PnrStatus(
      trainName: json['train_name'],
      startStation: json['start_station'],
      endStation: json['end_station'],
      coachName: json['coach_name'],
      seatNo: json['seat_no'],
      seatType: json['seat_type'],
      bookingStatus: json['booking_status'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}
