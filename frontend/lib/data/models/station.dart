// ignore_for_file: constant_identifier_names

enum StationType {
  JN,
  TM,
  HT,
  ST,
}

class StationResponse {
  final int stationId;
  final String stationName;
  final String stationType;

  StationResponse({
    required this.stationId,
    required this.stationName,
    required this.stationType,
  });

  factory StationResponse.fromJson(Map<String, dynamic> json) {
    return StationResponse(
      stationId: json['station_id'] as int,
      stationName: json['station_name'] as String,
      stationType: json['station_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'station_id': stationId,
      'station_name': stationName,
      'station_type': stationType,
    };
  }
}
