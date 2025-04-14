class JourneyDetails {
  final int journeyId;
  final String startTime;
  final String endTime;
  final int trainId;
  final int startStationId;
  final int endStationId;
  final String startStationName;
  final String endStationName;

  JourneyDetails({
    required this.journeyId,
    required this.startTime,
    required this.endTime,
    required this.trainId,
    required this.startStationId,
    required this.endStationId,
    required this.startStationName,
    required this.endStationName,
  });

  factory JourneyDetails.fromJson(Map<String, dynamic> json) {
    return JourneyDetails(
      journeyId: json['journey_id'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      trainId: json['train_id'] as int,
      startStationId: json['start_station_id'] as int,
      endStationId: json['end_station_id'] as int,
      startStationName: json['start_station_name'] as String,
      endStationName: json['end_station_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'journey_id': journeyId,
      'start_time': startTime,
      'end_time': endTime,
      'train_id': trainId,
      'start_station_id': startStationId,
      'end_station_id': endStationId,
      'start_station_name': startStationName,
      'end_station_name': endStationName,
    };
  }
}

class CreateJourneyRequest {
  final String startTime;
  final String endTime;
  final int trainId;
  final int startStationId;
  final int endStationId;

  CreateJourneyRequest({
    required this.startTime,
    required this.endTime,
    required this.trainId,
    required this.startStationId,
    required this.endStationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime,
      'end_time': endTime,
      'train_id': trainId,
      'start_station_id': startStationId,
      'end_station_id': endStationId,
    };
  }
}
