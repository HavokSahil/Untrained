class RouteResponse {
  final int routeId;
  final String routeName;
  final int sourceStationId;
  final int numStations;
  final double totalDistance;

  RouteResponse({
    required this.routeId,
    required this.routeName,
    required this.sourceStationId,
    required this.numStations,
    required this.totalDistance,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      routeId: json['route_id'],
      routeName: json['route_name'],
      sourceStationId: json['source_station_id'],
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
  final double distance;

  RouteStation({required this.stationId, required this.distance});

  factory RouteStation.fromJson(Map<String, dynamic> json) {
    return RouteStation(
      stationId: json['station_id'] ?? 0,
      distance: (json['distance'] ?? 0).toDouble(),
    );
  }
}

class RouteStationInfo {
  final int routeId;
  final String routeName;
  final int sourceStationId;
  final List<RouteStation> stations;
  final double totalDistance;

  RouteStationInfo({
    required this.routeId,
    required this.routeName,
    required this.sourceStationId,
    required this.stations,
    required this.totalDistance,
  });

  factory RouteStationInfo.fromJson(Map<String, dynamic> json) {
    return RouteStationInfo(
      routeId: json['route_id'] ?? 0,
      routeName: json['route_name'] ?? 'Unknown',
      sourceStationId: json['source_station_id'] ?? 0,
      totalDistance: (json['total_distance'] ?? 0).toDouble(),
      stations: (json['stations'] as List)
          .map((e) => RouteStation.fromJson(e))
          .toList(),
    );
  }
}
