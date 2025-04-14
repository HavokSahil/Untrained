// ignore_for_file: constant_identifier_names

enum TrainType {
    EX, // Express
    ML, // Mail
    SF, // Superfast
    VB, // Vande Bharat
    MM, // MEMU
    IN // Intercity
}

class Train {
  final int trainNo;
  final String trainName;
  final TrainType trainType;

  Train({
    required this.trainNo,
    required this.trainName,
    required this.trainType
  });

  factory Train.fromJson(Map<String, dynamic> json) {
    return Train(
      trainNo: json['train_no'],
      trainName: json['train_name'],
      trainType: TrainType.values.firstWhere((e) => e.toString() == 'TrainType.${json['train_type']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'train_no': trainNo,
      'train_name': trainName,
      'train_type': trainType.toString().split('.').last
    };
  }
}

class TrainDetails extends Train {
  final int coaches;
  final int seats;
  final int journeys;
  final int upcomingJourneys;

  TrainDetails({
    required super.trainNo,
    required super.trainName,
    required super.trainType,
    required this.coaches,
    required this.seats,
    required this.journeys,
    required this.upcomingJourneys
  });

  @override
  factory TrainDetails.fromJson(Map<String, dynamic> json) {
    return TrainDetails(
      trainNo: json['train_no'],
      trainName: json['train_name'],
      trainType: TrainType.values.firstWhere((e) => e.toString() == 'TrainType.${json['train_type']}'),
      coaches: json['coaches'],
      seats: json['seats'],
      journeys: json['journeys'],
      upcomingJourneys: json['upcoming_journeys']
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'train_id': trainNo,
      'train_name': trainName,
      'train_type': trainType.toString().split('.').last,
      'total_coaches': coaches,
      'total_seats': seats,
      'total_journeys': journeys,
      'upcoming_journeys': upcomingJourneys
    };
  }
}
