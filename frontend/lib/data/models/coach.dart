// ignore_for_file: constant_identifier_names

enum CoachType {
  SL,
  AC3,
  AC2,
  AC1,
  CC,
  FC,
  S2
}


// Coach type to string mapping
const Map<CoachType, String> COACH_TYPE_MAP = {
  CoachType.SL: "SL",
  CoachType.AC3: "AC3",
  CoachType.AC2: "AC2",
  CoachType.AC1: "AC1",
  CoachType.CC: "CC",
  CoachType.FC: "FC",
  CoachType.S2: "2S",
};


class CoachResponse {
  final int coachId;
  final String coachName;
  final String coachType;
  final double fare;
  final int trainId;
  final int totalSeats;

  CoachResponse({
    required this.coachId,
    required this.coachName,
    required this.coachType,
    required this.fare,
    required this.trainId,
    required this.totalSeats,
  });

  factory CoachResponse.fromJson(Map<String, dynamic> json) {
    return CoachResponse(
      coachId: json['coach_id'],
      coachName: json['coach_name'],
      coachType: json['coach_type'],
      fare: (json['fare'] as num).toDouble(),
      trainId: json['train_id'],
      totalSeats: json['total_seats'],
    );
  }
}


class CreateCoach {
  final String coachName;
  final String coachType;
  final double fare;
  final int trainId;

  CreateCoach({
    required this.coachName,
    required this.coachType,
    required this.fare,
    required this.trainId,
  });

  Map<String, dynamic> toJson() {
    return {
      'coach_name': coachName,
      'coach_type': coachType,
      'fare': fare,
      'train_id': trainId,
    };
  }
}
