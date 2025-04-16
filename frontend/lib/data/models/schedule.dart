class ScheduleDetails {
  final int id;
  final int journeyId;
  final int stationId;
  final String stationName;
  final int stopNumber;
  final String arrivalTime;
  final String departureTime;
  final int? routeId;
  final double? distance;
  double? cumulativeDistance;

  ScheduleDetails({
    required this.id,
    required this.journeyId,
    required this.stationId,
    required this.stationName,
    required this.stopNumber,
    required this.arrivalTime,
    required this.departureTime,
    required this.routeId,
    required this.distance,
  });

  // Setter for cumulative distance
  set setCumulativeDistance(double distance) {
    cumulativeDistance = distance;
  }

  factory ScheduleDetails.fromJson(Map<String, dynamic> json) {
    return ScheduleDetails(
      id: json['sched_id'],
      journeyId: json['journey_id'],
      stationId: json['station_id'],
      stationName: json['station_name'],
      stopNumber: json['stop_number'],
      arrivalTime: json['sched_toa'],
      departureTime: json['sched_tod'],
      routeId: json['route_id'],
      distance: json['distance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'journey_id': journeyId,
      'station_id': stationId,
      'stop_number': stopNumber,
      'sched_toa': arrivalTime,
      'sched_tod': departureTime,
    };
  }
}

class CreateScheduleRequest {
  final int journeyId;
  final int stationId;
  final int stopNumber;
  final String arrivalTime;
  final String departureTime;
  final int? routeId;

  CreateScheduleRequest({
    required this.journeyId,
    required this.stationId,
    required this.stopNumber,
    required this.arrivalTime,
    required this.departureTime,
    this.routeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'journey_id': journeyId,
      'station_id': stationId,
      'stop_number': stopNumber,
      'sched_toa': arrivalTime,
      'sched_tod': departureTime,
      'route_id': routeId,
    };
  }
}

class UpdateScheduleRequest {
  final String? arrivalTime;
  final String? departureTime;
  final int? stopNumber;
  final int? routeId;

  UpdateScheduleRequest({
    this.arrivalTime,
    this.departureTime,
    this.stopNumber,
    this.routeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'sched_toa': arrivalTime,
      'sched_tod': departureTime,
      'stop_number': stopNumber,
      'route_id': routeId,
    };
  }
}

class JourneyBetweenStations {
  final int journeyId;
  final int? trainId;
  final String? trainName;
  final int? startStationId;
  final int? startScheduleId;
  final String? startStation;
  final int? endStationId;
  final int? endScheduleId;
  final String? endStation;
  final String? startTime;
  final String? endTime;
  final int? startStopNumber;
  final int? endStopNumber;
  final int? travelTime;

  JourneyBetweenStations({
    required this.journeyId,
    this.trainId,
    this.trainName,
    this.startStationId,
    this.startScheduleId,
    this.startStation,
    this.endStationId,
    this.endScheduleId,
    this.endStation,
    this.startTime,
    this.endTime,
    this.startStopNumber,
    this.endStopNumber,
    this.travelTime,
  });

  factory JourneyBetweenStations.fromJson(Map<String, dynamic> json) {
    return JourneyBetweenStations(
      journeyId: json['journey_id'],
      trainId: json['train_id'],
      trainName: json['train_name'],
      startStationId: json['start_station_id'],
      startScheduleId: json['start_schedule_id'],
      startStation: json['start_station'],
      endStationId: json['end_station_id'],
      endScheduleId: json['end_schedule_id'],
      endStation: json['end_station'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      startStopNumber: json['start_stop_number'],
      endStopNumber: json['end_stop_number'],
      travelTime: json['travel_time'],
    );
  }
}