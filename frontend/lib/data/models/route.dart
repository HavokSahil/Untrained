class RouteResponse {
  final int routeId;
  final String routeName;
  final int sourceStationId;
  final String sourceStationName;
  final int numStations;
  final double totalDistance;

  RouteResponse({
    required this.routeId,
    required this.routeName,
    required this.sourceStationId,
    required this.sourceStationName,
    required this.numStations,
    required this.totalDistance,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      routeId: json['route_id'],
      routeName: json['route_name'],
      sourceStationId: json['source_station_id'],
      sourceStationName: json['source_station_name'],
      numStations: json['num_stations'],
      totalDistance: json['total_distance'],
    );
  }
}

class CreateRoute {
  final String routeName;
  final int sourceStationId;

  CreateRoute({
    required this.routeName,
    required this.sourceStationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'route_name': routeName,
      'source_station_id': sourceStationId,
    };
  }
}

class RouteStation {
  final int stationId;
  final String stationName;
  final double distance;

  RouteStation({required this.stationId, required this.stationName, required this.distance});

  factory RouteStation.fromJson(Map<String, dynamic> json) {
    return RouteStation(
      stationId: json['station_id'] ?? 0,
      stationName: json['source_station_name'] ?? 'Unknown',
      distance: (json['distance'] ?? 0).toDouble(),
    );
  }
}

class RouteStationInfo {
  final int routeId;
  final String routeName;
  final int sourceStationId;
  final String sourceStationName;
  final List<RouteStation> stations;
  final double totalDistance;

  RouteStationInfo({
    required this.routeId,
    required this.routeName,
    required this.sourceStationId,
    required this.sourceStationName,
    required this.stations,
    required this.totalDistance,
  });

  factory RouteStationInfo.fromJson(Map<String, dynamic> json) {
    return RouteStationInfo(
      routeId: json['route_id'] ?? 0,
      routeName: json['route_name'] ?? 'Unknown',
      sourceStationId: json['source_station_id'] ?? 0,
      sourceStationName: json['source_station_name'] ?? 'Unknown',
      totalDistance: (json['total_distance'] ?? 0).toDouble(),
      stations: (json['stations'] as List)
          .map((e) => RouteStation.fromJson(e))
          .toList(),
    );
  }
}


class RoutesBetweenStations {
  final int routeId;
  final String routeName;
  final int sourceStationId;
  final int destinationStationId;
  final double distance;

  RoutesBetweenStations({
    required this.routeId,
    required this.routeName,
    required this.sourceStationId,
    required this.destinationStationId,
    required this.distance,
  });

  factory RoutesBetweenStations.fromJson(Map<String, dynamic> json) {
    return RoutesBetweenStations(
      routeId: json['route_id'],
      routeName: json['route_name'],
      sourceStationId: json['source_station_id'],
      destinationStationId: json['destination_station_id'],
      distance: (json['distance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'route_name': routeName,
      'source_station_id': sourceStationId,
      'destination_station_id': destinationStationId,
      'distance': distance,
    };
  }
}

class RelativeStation {
  final int stationId;
  final String stationName;
  final double distanceFromGivenStation;

  RelativeStation({
    required this.stationId,
    required this.stationName,
    required this.distanceFromGivenStation,
  });

  factory RelativeStation.fromJson(Map<String, dynamic> json) {
    return RelativeStation(
      stationId: json['station_id'],
      stationName: json['station_name'],
      distanceFromGivenStation: (json['distance_from_given_station'] as num).toDouble(),
    );
  }
}
