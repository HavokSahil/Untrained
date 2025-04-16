import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/data/models/booking.dart';
import 'package:frontend/data/models/coach.dart';
import 'package:frontend/data/models/journey.dart';
import 'package:frontend/data/models/passenger.dart';
import 'package:frontend/data/models/route.dart';
import 'package:frontend/data/models/schedule.dart';
import 'package:frontend/data/models/seat.dart';
import 'package:frontend/data/models/station.dart';
import 'package:frontend/data/models/train.dart';
import 'package:frontend/data/models/transaction.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({this.data, this.error, this.statusCode});

  bool get isSuccess => error == null;
}

class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int limit;
  final int offset;
  final int total;

  PaginatedResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
    {String itemsKey = 'trains'}
  ) {
    return PaginatedResponse<T>(
      items: (json['data'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      total: json['total'] as int,
    );
  }
}


class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  static Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        return ApiResponse(data: user, statusCode: response.statusCode);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Login failed",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<User>> signup(String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': role}),
      );

      if (response.statusCode == 201) {
        final user = User.fromJson(jsonDecode(response.body));
        return ApiResponse(data: user, statusCode: response.statusCode);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Signup failed",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<Train>> getTrainByNo(int trainNo) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/trains/id/$trainNo'));

      if (response.statusCode == 200) {
        final train = Train.fromJson(jsonDecode(response.body));
        return ApiResponse(data: train, statusCode: response.statusCode);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Train not found",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<Train>> addTrain(int trainNo, String trainName, String trainType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/trains/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'train_no': trainNo, 'train_name': trainName, 'train_type': trainType}),
      );

      if (response.statusCode == 201) {
        final train = Train.fromJson(jsonDecode(response.body));
        return ApiResponse(data: train, statusCode: response.statusCode);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to add train",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<PaginatedResponse<Train>>> getTrains({
    int page = 1,
    int limit = 5,
    int? trainNo,
    String? trainName,
    String? trainType,
    String sort = 'train_id',
  }) async {
    try {
      final queryParams = {
        'page': '$page',
        'limit': '$limit',
        'sort': sort,
        if (trainNo != null) 'train_no': '$trainNo',
        if (trainName != null && trainName.isNotEmpty) 'train_name': trainName,
        if (trainType != null && trainType.isNotEmpty && trainType != 'ALL') 'train_type': trainType
      };

      final uri = Uri.parse('$baseUrl/trains').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final paginatedTrains = PaginatedResponse<Train>.fromJson(
          json,
          (item) => Train.fromJson(item),
        );
        return ApiResponse(data: paginatedTrains, statusCode: response.statusCode);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to fetch trains",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<PaginatedResponse<TrainDetails>>> getDetailedTrains({
    int page = 1,
    int limit = 5,
    int? trainNo,
    String? trainName,
    String? trainType,
  }) async {
    try {
      final queryParams = {
        'page': '$page',
        'limit': '$limit',
        if (trainNo != null) 'train_no': '$trainNo',
        if (trainName != null && trainName.isNotEmpty) 'train_name': trainName,
        if (trainType != null && trainType.isNotEmpty) 'train_type': trainType,
      };

      final uri = Uri.parse('$baseUrl/trains/detailed').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final paginated = PaginatedResponse<TrainDetails>.fromJson(
          json,
          (item) => TrainDetails.fromJson(item),
        );
        return ApiResponse(
          data: paginated,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to fetch detailed trains",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<PaginatedResponse<CoachResponse>>> getCoachesForTrain({
    required int trainId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': '$page',
        'limit': '$limit',
      };

      final uri = Uri.parse('$baseUrl/trains/coaches/id/$trainId').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final paginated = PaginatedResponse<CoachResponse>.fromJson(
          json,
          (item) => CoachResponse.fromJson(item),
          itemsKey: 'coaches',
        );
        return ApiResponse(data: paginated, statusCode: response.statusCode);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to fetch coaches",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<void>> createCoach(CreateCoach coach) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/coaches/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(coach.toJson()),
      );

      if (response.statusCode == 201) {
        return ApiResponse(statusCode: response.statusCode);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to create coach",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<PaginatedResponse<SeatResponse>>> getSeatsByCoach({
    required int trainId,
    required int coachId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': '$page',
        'limit': '$limit',
      };

      final uri = Uri.parse('$baseUrl/coaches/seats/id/$coachId')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final paginated = PaginatedResponse<SeatResponse>.fromJson(
          json,
          (item) => SeatResponse.fromJson(item),
          itemsKey: 'seats',
        );
        return ApiResponse(data: paginated, statusCode: response.statusCode);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to fetch seats",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  /// Create a seat under a coach
  static Future<ApiResponse<void>> createSeat({
    required int trainId,
    required int coachId,
    required CreateSeat seat,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/seats/add');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(seat.toJson()),
      );

      if (response.statusCode == 201) {
        return ApiResponse(statusCode: response.statusCode);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to create seat",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<StationResponse>> createStation({
    required String stationName,
    required String stationType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/station/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'station_name': stationName,
          'station_type': stationType,
        }),
      );

      if (response.statusCode == 201) {
        return ApiResponse(statusCode: response.statusCode);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to create station",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<PaginatedResponse<StationResponse>>> getStationByName(
    String stationName,
  ) async {
    try {
      final queryParams = {
        'search': stationName,
      };
      
      final response = await http.get(Uri.parse('$baseUrl/station').replace(queryParameters: queryParams));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final paginated = PaginatedResponse<StationResponse>.fromJson(
          json,
          (item) => StationResponse.fromJson(item),
          itemsKey: 'stations',
        );
        return ApiResponse(
          data: paginated,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Station not found",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<PaginatedResponse<StationResponse>>> getStations({
    int page = 1,
    int limit = 5,
    int? stationId,
    String? stationName,
    String? stationType,
  }) async {
    try {
      final queryParams = {
        'page': '$page',
        'limit': '$limit',
        if (stationId != null) 'station_id': '$stationId',
        if (stationName != null && stationName.isNotEmpty) 'station_name': stationName,
        if (stationType != null && stationType.isNotEmpty) 'station_type': stationType,
      };

      final uri = Uri.parse('$baseUrl/station/all').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final paginated = PaginatedResponse<StationResponse>.fromJson(
          json,
          (item) => StationResponse.fromJson(item),
        );
        return ApiResponse(
          data: paginated,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to fetch detailed trains",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

   static Future<ApiResponse<PaginatedResponse<RouteResponse>>> getRoutes({
    int page = 1,
    int limit = 10,
    String? routeName,
    int? routeId,
    String? routeStation,
  }) async {
    final uri = Uri.parse('$baseUrl/route').replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
      if (routeName != null) 'route_name': routeName,
      if (routeId != null) 'route_id': routeId.toString(),
      if (routeStation != null) 'route_station': routeStation,
    });

    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final paginated = PaginatedResponse<RouteResponse>.fromJson(
          json,
          (item) => RouteResponse.fromJson(item),
        );
        return ApiResponse(
          data: paginated,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to fetch detailed trains",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<void>> createRoute(CreateRoute route) async {
    final uri = Uri.parse('$baseUrl/route/add');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(route.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(statusCode: response.statusCode);
      } else {
        return ApiResponse(
            error: "Failed to create route", statusCode: response.statusCode);
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<void>> addIntermediateStation({
    required int routeId,
    required int stationId,
    required double distance,
  }) async {
    final uri = Uri.parse('$baseUrl/route/id/$routeId/add');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'station_id': stationId,
          'distance': distance,
        }),
      );

      if (response.statusCode == 201) {
        return ApiResponse(statusCode: 201);
      } else {
        return ApiResponse(error: response.body, statusCode: response.statusCode);
      }
    } catch (e) {
      return ApiResponse(error: e.toString(), statusCode: 500);
    }
  }

  static Future<ApiResponse<RouteStationInfo>> getRouteStations(int routeId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/route/id/$routeId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final routeInfo = RouteStationInfo.fromJson(jsonData);
        return ApiResponse(data: routeInfo);
      } else {
        return ApiResponse(error: "Failed to fetch stations");
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<PaginatedResponse<JourneyDetails>>> getDetailedJourneys({
    int page = 1,
    int limit = 5,
    int? journeyId,
    int? trainId,
    String? startStationName,
    String? endStationName,
  }) async {
    try {
      final queryParams = {
        'page': '$page',
        'limit': '$limit',
        if (journeyId != null) 'journey_id': '$journeyId',
        if (trainId != null) 'train_no': '$trainId',
        if (startStationName != null) 'start_station_name': startStationName,
        if (endStationName != null) 'end_station_name': endStationName,
      };

      final uri = Uri.parse('$baseUrl/journeys').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final paginated = PaginatedResponse<JourneyDetails>.fromJson(
          json,
          (item) => JourneyDetails.fromJson(item),
          itemsKey: 'data', // if your backend returns it as `data: [...]`
        );
        return ApiResponse(
          data: paginated,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to fetch detailed journeys",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<PaginatedResponse<JourneyDetails>>> getAllJourneys({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/journeys').replace(queryParameters: {
        'page': '$page',
        'limit': '$limit',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final paginated = PaginatedResponse<JourneyDetails>.fromJson(
          json,
          (item) => JourneyDetails.fromJson(item),
        );
        return ApiResponse(data: paginated, statusCode: response.statusCode);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch journeys',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<void>> createJourney(CreateJourneyRequest newJourney) async {
    try {
      final uri = Uri.parse('$baseUrl/journeys/add');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newJourney.toJson()),
      );

      if (response.statusCode == 201) {
        return ApiResponse(statusCode: 201);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to create journey',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<PaginatedResponse<JourneyBetweenStations>>> getJourneysBetweenStations(
    {
      required int sourceStationId,
      required int destinationStationId,
      required String date,
    }
  ) async {

    try {
      final uri = Uri.parse('$baseUrl/journeys/search').replace(queryParameters: {
        'source_station_id': sourceStationId.toString(),
        'destination_station_id': destinationStationId.toString(),
        // Example Date format: 2025-04-15
        'journey_date': date,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final paginated = PaginatedResponse<JourneyBetweenStations>.fromJson(
          json,
          (item) => JourneyBetweenStations.fromJson(item),
          itemsKey: 'journeys',
        );
        return ApiResponse(data: paginated, statusCode: response.statusCode);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch journeys',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<JourneyDetails>> getJourneyById(int journeyId) async {
    try {
      final uri = Uri.parse('$baseUrl/journeys/id/$journeyId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse(
          data: JourneyDetails.fromJson(json),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Journey not found',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<void>> updateJourney(int journeyId, CreateJourneyRequest updatedJourney) async {
    try {
      final uri = Uri.parse('$baseUrl/journeys/id/$journeyId/update');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedJourney.toJson()),
      );

      if (response.statusCode == 200) {
        return ApiResponse(statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to update journey',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<List<JourneyDetails>>> getJourneysByTrain(int trainId) async {
    try {
      final uri = Uri.parse('$baseUrl/journeys/train/id/$trainId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List;
        final journeys = jsonList.map((e) => JourneyDetails.fromJson(e)).toList();
        return ApiResponse(data: journeys, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch journeys by train',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<List<ScheduleDetails>>> getSchedulesByJourney(int journeyId) async {
    try {
      final uri = Uri.parse('$baseUrl/schedules/journey/$journeyId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List;
        final schedules = jsonList.map((e) => ScheduleDetails.fromJson(e)).toList();
        return ApiResponse(data: schedules, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch schedules',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<void>> createSchedule(CreateScheduleRequest schedule) async {
    try {
      final uri = Uri.parse('$baseUrl/schedules/add');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(schedule.toJson()),
      );

      if (response.statusCode == 201) {
        return ApiResponse(statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to create schedule',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<void>> deleteSchedule(int scheduleId) async {
    try {
      final uri = Uri.parse('$baseUrl/$scheduleId/delete');
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        return ApiResponse(statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to delete schedule',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<void>> updateSchedule(int scheduleId, UpdateScheduleRequest updatedSchedule) async {
    try {
      final uri = Uri.parse('$baseUrl/schedules/update/id/$scheduleId');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedSchedule.toJson()),
      );

      if (response.statusCode == 200) {
        return ApiResponse(statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to update schedule',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }
  static Future<ApiResponse<List<RoutesBetweenStations>>> getRoutesBetweenStations({
    required int sourceStationId,
    required int destinationStationId,
  }) async {
    try {
      final queryParams = {
        'source_station_id': sourceStationId.toString(),
        'destination_station_id': destinationStationId.toString(),
      };
      final uri = Uri.parse(
          '$baseUrl/route/between').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List<dynamic>;
        final routes = jsonList
            .map((routeJson) => RoutesBetweenStations.fromJson(routeJson))
            .toList();

        return ApiResponse(
          data: routes,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch routes',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<List<RelativeStation>>> getStationsRelativeTo({
    required int routeId,
    required int stationId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/route/relative').replace(queryParameters: {
        'route_id': routeId.toString(),
        'station_id': stationId.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List<dynamic>;
        final stations = jsonList
            .map((json) => RelativeStation.fromJson(json))
            .toList();

        return ApiResponse(
          data: stations,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch relative stations',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<List<SeatCount>>> getReservedSeatCount({
    required int journeyId,
    required String type,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/booking/seat/$type/$journeyId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final data = jsonList.map((e) => SeatCount.fromJson(e)).toList();
        return ApiResponse(data: data, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to fetch seat count",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<List<SeatCount>>> getTotalSeatCount({
    required int journeyId,
    required String type,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/seats/total/$type/$journeyId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final data = jsonList.map((e) => SeatCount.fromJson(e)).toList();
        return ApiResponse(data: data, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to fetch seat count",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<List<CoachFare>>> getCoachFare({
    required int journeyId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/journeys/fare/$journeyId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final data = jsonList.map((e) => CoachFare.fromJson(e)).toList();
        return ApiResponse(data: data, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? "Failed to fetch fare",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

   static Future<ApiResponse<int>> createPaymentTransaction(CreateTransaction newTransaction) async {
    try {
      final uri = Uri.parse('$baseUrl/transaction/add');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newTransaction.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        // Assuming the response body includes txn_id

        final txnId = jsonResponse['txn_id'];

        // Return the txnId if needed in your response or for further use
        return ApiResponse(statusCode: 201, data: txnId);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to create transaction',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  // Update the payment transaction status by transaction ID
  static Future<ApiResponse<void>> updatePaymentTransactionStatus(int txnId, String status) async {
    try {
      final uri = Uri.parse('$baseUrl/transaction/update');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "txn_id": txnId,
          "txn_status": status,
        }),
      );
      if (response.statusCode == 200) {
        return ApiResponse(statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to update transaction status',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  // Get all transactions
  static Future<ApiResponse<List<PaymentTransaction>>> getAllTransactions() async {
    try {
      final uri = Uri.parse('$baseUrl/transaction/all');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List;
        final transactions = jsonList.map((e) => PaymentTransaction.fromJson(e)).toList();
        return ApiResponse(data: transactions, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch transactions',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<int>> createGroupBooking(GroupBookingRequest request) async {
    try {
      final uri = Uri.parse('$baseUrl/booking/book');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final txnId = json['txn_id'];
        return ApiResponse(data: txnId, statusCode: 201);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to create group booking',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<List<BookingDetail>>> getBookingDetails(String email) async {
    try {
      final uri = Uri.parse('$baseUrl/booking/details?email=$email');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List;
        final bookings = jsonList.map((e) => BookingDetail.fromJson(e)).toList();
        return ApiResponse(data: bookings, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch booking details',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<void>> cancelBooking(CancelBookingRequest request) async {
    try {
      final uri = Uri.parse('$baseUrl/booking/cancel');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return ApiResponse(statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to cancel booking',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  static Future<ApiResponse<PnrStatus>> getPnrStatus(int pnr) async {
    try {
      final uri = Uri.parse('$baseUrl/pnr/$pnr');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final pnrStatus = PnrStatus.fromJson(jsonDecode(response.body));
        return ApiResponse(data: pnrStatus, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch PNR status',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }


  // Get total number of journeys
  static Future<ApiResponse<int>> getTotalNumberOfJourneys() async {
    try {
      final uri = Uri.parse('$baseUrl/stat/total-journeys');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final totalJourneys = json['total_journeys'];
        return ApiResponse(data: totalJourneys, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch total journeys',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  // Get busiest route
  static Future<ApiResponse<Map<String, dynamic>>> getBusiestRoute() async {
    try {
      final uri = Uri.parse('$baseUrl/stat/busiest-route');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse(data: json, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch busiest route',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  // Get total passengers traveling by journey
  static Future<ApiResponse<List<Map<String, dynamic>>>> getTotalPassengersTraveling() async {
    try {
      final uri = Uri.parse('$baseUrl/stat/total-passengers');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List;
        final passengers = jsonList.map((e) => e as Map<String, dynamic>).toList();
        return ApiResponse(data: passengers, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch passengers',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  // Get gender distribution
  static Future<ApiResponse<List<Map<String, dynamic>>>> getGenderDistribution() async {
    try {
      final uri = Uri.parse('$baseUrl/stat/gender-distribution');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List;
        final genderStats = jsonList.map((e) => e as Map<String, dynamic>).toList();
        return ApiResponse(data: genderStats, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch gender distribution',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  // Get busiest station
  static Future<ApiResponse<Map<String, dynamic>>> getBusiestStation() async {
    try {
      final uri = Uri.parse('$baseUrl/stat/busiest-station');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse(data: json, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch busiest station',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  // Rank running trains by bookings
  static Future<ApiResponse<List<Map<String, dynamic>>>> rankRunningTrainsByBookings() async {
    try {
      final uri = Uri.parse('$baseUrl/stat/rank-running-trains');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List;
        final trains = jsonList.map((e) => e as Map<String, dynamic>).toList();
        return ApiResponse(data: trains, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch running trains',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  // Get busiest time period
  static Future<ApiResponse<List<Map<String, dynamic>>>> getBusiestTimePeriod() async {
    try {
      final uri = Uri.parse('$baseUrl/stat/busiest-time-period');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List;
        final timePeriods = jsonList.map((e) => e as Map<String, dynamic>).toList();
        return ApiResponse(data: timePeriods, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch busiest time period',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  // Get reservation status distribution
  static Future<ApiResponse<List<Map<String, dynamic>>>> getReservationStatusDistribution() async {
    try {
      final uri = Uri.parse('$baseUrl/stat/reservation-status-distribution');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List;
        final statusDistribution = jsonList.map((e) => e as Map<String, dynamic>).toList();
        return ApiResponse(data: statusDistribution, statusCode: 200);
      } else {
        return ApiResponse(
          error: jsonDecode(response.body)['error'] ?? 'Failed to fetch reservation status distribution',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }
}
