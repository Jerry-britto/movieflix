import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:netflix_app/components/Card/movie_card.dart';
import 'package:netflix_app/screens/details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic>? movies;
  final TextEditingController _movieController = TextEditingController();
  bool isLoading = false;

  displayMessage({String title = "Error occured", required String message}) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  searchForMovie(String movie) async {
    try {
      setState(() {
        isLoading = true;
      });
      var url = Uri.https('api.tvmaze.com', '/search/shows', {'q': movie});
      var response = await http.get(url);
      debugPrint("Response status: ${response.statusCode}");
      setState(() {
        movies = jsonDecode(response.body.toString());
      });
      if (movies == null || movies!.isEmpty) {
        displayMessage(
          title: "Search result not available",
          message: "Movie not available",
        );
        return;
      }
    } catch (e) {
      debugPrint("error occured while searching movie $e");
      displayMessage(
        message:
            "A problem occured while searching the movie. Please try again or report to the team",
      );
    } finally {
      debugPrint("Search result: $movies");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 15),
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _movieController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Search...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ), // Search icon
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                  ),
                  onPressed: () {
                    if (_movieController.text.isNotEmpty) {
                      if (movies != null && movies!.isNotEmpty) movies!.clear();
                      searchForMovie(_movieController.text);
                    } else {
                      displayMessage(
                        title: "Invalid movie name",
                        message: "Kindly provide the movie name",
                      );
                    }
                  },
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (isLoading)
              SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),

            if (movies != null && movies!.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: movies!.length,
                itemBuilder: (context, index) {
                  final movie = movies![index]["show"];
                  return GestureDetector(
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MovieDetails(movieRecord: movie),
                          ),
                        ),
                    child: MovieCard(
                      name: movie["name"] ?? "Unknown Title",
                      summary: movie["summary"] ?? "No Summary Available",
                      thumbnail:
                          movie["image"] != null
                              ? movie["image"]["original"]
                              : null,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
