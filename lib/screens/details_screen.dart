import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetails extends StatefulWidget {
  const MovieDetails({super.key, required this.movieRecord});
  final dynamic movieRecord;

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  @override
  Widget build(BuildContext context) {
    final movie = widget.movieRecord;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          movie["name"] ?? "Movie Details",
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    movie["image"]?["original"] ??
                        "https://via.placeholder.com/400x600?text=Image+Not+Available",
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 100,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                movie["name"] ?? "Unknown Title",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: (movie["genres"] as List<dynamic>?)
                        ?.map<Widget>(
                          (genre) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(genre),
                              backgroundColor: Colors.redAccent,
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList() ??
                    [const Text("No genres available", style: TextStyle(color: Colors.white70))],
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoText("Rating: ${movie["rating"]?["average"] ?? "N/A"}"),
                  _buildInfoText("Status: ${movie["status"] ?? "Unknown"}"),
                  _buildInfoText("Language: ${movie["language"] ?? "Unknown"}"),
                ],
              ),
              const SizedBox(height: 16),

              if ((movie["schedule"]?["days"] as List<dynamic>?)?.isNotEmpty ?? false)
                Text(
                  "Schedule: ${movie["schedule"]["days"].join(", ")} at ${movie["schedule"]["time"] ?? "Unknown"}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                )
              else
                _buildInfoText("Schedule: Not available"),
              const SizedBox(height: 16),

              Text(
                "Overview",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _parseHtmlString(movie["summary"] ?? "No overview available."),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Next Episode Link
              if (movie["links"]?["nextepisode"] != null)
                ElevatedButton(
                  onPressed: () {
                    _launchURL(movie["links"]["nextepisode"]["href"]);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    "Next Episode: ${movie["links"]["nextepisode"]["name"] ?? "Details"}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                _buildInfoText("Next Episode: Not available"),

              ElevatedButton(
                onPressed: () {
                  _launchURL(movie["officialSite"]);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Watch Now",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _parseHtmlString(String htmlString) {
    if (htmlString.isEmpty) return "No information available.";
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }

  Widget _buildInfoText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 16),
    );
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("URL not available."),
        ),
      );
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not launch $urlString."),
        ),
      );
    }
  }
}
