import 'package:flutter/material.dart';
import 'package:frontend/data/models/route.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/screens/admin/dialog/add_route_dialog.dart';
import 'package:frontend/screens/admin/route_detail_screen.dart';
import 'package:frontend/widgets/app_bar.dart';

class RouteScreen extends StatefulWidget {
  final User user;
  const RouteScreen({super.key, required this.user});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  List<RouteResponse> routes = [];

  int page = 1;
  int limit = 10;
  int total = 0;

  String searchTerm = '';

  bool isLoading = false;
  String? searchBy = RouteSearchBy.values.first.name;

  final TextEditingController _searchController = TextEditingController();

  void fetchRoutes() async {
    setState(() => isLoading = true);
    final response = await ApiService.getRoutes(
      page: page,
      limit: limit,
      routeName: (searchBy == RouteSearchBy.Name.name) ? searchTerm.trim() : null,
      routeId: (searchBy == RouteSearchBy.Id.name) ? int.tryParse(searchTerm.trim()) : null,
      routeStation: (searchBy == RouteSearchBy.Station.name) ? searchTerm.trim() : null,
    );

    if (response.isSuccess && response.data != null) {
      final PaginatedResponse<RouteResponse> paginated = response.data!;
      setState(() {
        routes = paginated.items;
        total = paginated.total;
      });
    } else {
      // Show error if needed
    }
    setState(() => isLoading = false);
  }

  void onPressRoute(RouteResponse route) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RouteDetailScreen(user: widget.user, route: route),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchRoutes();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user, title: "Route"),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          children: [
            // Search bar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 124,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddRouteDialog(
                            user: widget.user,
                            onRouteCreated: fetchRoutes,
                          ),
                        );
                      },
                    child: const Text("Add Route", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),)
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  width: 420,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 32),
                      hintText: 'Search by $searchBy',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF272727),
                      focusColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        page = 1;
                        searchTerm = value.trim();
                      });
                      fetchRoutes();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  width: 124,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9)),
                      foregroundColor: WidgetStatePropertyAll(Colors.black)
                    ),
                    onPressed: () {
                      setState(() {
                        page = 1;
                        searchTerm = _searchController.text.trim();
                      });
                      fetchRoutes();
                    },
                    child: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
                SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  width: 124,
                  child: DropdownButtonFormField<String>(
                    dropdownColor: Color(0xFF272727),
                    decoration: InputDecoration(
                      labelText: "Search By",
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    value: searchBy,
                    items: RouteSearchBy.values.map((e) {
                      return DropdownMenuItem(
                        value: e.name,
                        child: Text(e.name, style: TextStyle(color: Colors.white)),
                      );
                    }).toList()
                    ,
                    onChanged: (value) {
                      setState(() {
                        searchBy = value!;
                      });
                    },
                  )
                ),
              ],
            ),
            const SizedBox(height: 24,),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: const Text("Route Id", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(
                    width: 300,
                    child: const Text("Name", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(
                    width: 200,
                    child: const Text("Start Station", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(
                    width: 200,
                    child: const Text("No of Stations in Route", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(
                    width: 200,
                    child: const Text("Total Distance", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Train list
            if (isLoading)
              const CircularProgressIndicator()
            else if (routes.isEmpty)
              const Text("No route found", style: TextStyle(color: Colors.white))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: routes.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.black),
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Color(0xFF212121)),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ))
                        ),
                        onPressed: () => onPressRoute(route),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                route.routeId.toString().padLeft(6, '0'),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: Text(
                                route.routeName.toString().split('.').last,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: Text(
                                route.sourceStationName.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: Text(
                                route.numStations.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: Text(
                                "${route.totalDistance} km",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )

              ),

            const SizedBox(height: 16),

            // Pagination
            if (!isLoading)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: page > 1
                        ? () {
                            setState(() => page--);
                            fetchRoutes();
                          }
                        : () => (),
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9))),
                    child: const Text("Previous", style: TextStyle(color: Colors.black),),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Page $page of ${((total + limit - 1) / limit).floor()}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: (page * limit) < total
                        ? () {
                            setState(() => page++);
                            fetchRoutes();
                          }
                        : () => (),
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9))),
                    child: const Text("Next", style: TextStyle(color: Colors.black),),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}


enum RouteSearchBy {
  Id,
  Name,
  Station,
}