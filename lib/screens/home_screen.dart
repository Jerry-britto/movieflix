import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:netflix_app/components/Card/movie_card.dart';
import 'package:netflix_app/screens/details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic>? movies;
  bool isLoading = true;

  fetchMovies() async {
    try {
      var url = Uri.https('api.tvmaze.com', '/search/shows', {'q': 'all'});
      var response = await http.get(url);
      debugPrint("Response status: ${response.statusCode}");
      setState(() {
        movies = jsonDecode(response.body.toString());
      });
    } catch (e) {
      debugPrint("error while fetching movies due to $e");
    } finally {
      // debugPrint("API response: $movies");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
          isLoading
              ? Center(
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              )
              : movies == null || movies!.isEmpty
              ? const Center(
                child: Text(
                  "No Movies Available",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: movies!.length,
                itemBuilder: (context, index) {
                  final movie = movies![index]["show"];
                  return GestureDetector(
                    onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=> MovieDetails(movieRecord: movie))),
                    child: MovieCard(
                      name: movie["name"] ?? "Unknown Title",
                      summary: movie["summary"] ?? "No Summary Available",
                      thumbnail: movie["image"]?["original"],
                    ),
                  );
                },
              ),
    );
  }
}
