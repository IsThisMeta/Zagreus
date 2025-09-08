import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zagreus/modules/discover/core/api_keys.dart';

class TMDBApi {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p';
  
  // Get API key from secure config file
  static String get _apiKey => ApiKeys.tmdbApiKey;
  
  static String getImageUrl(String? path, {String size = 'original'}) {
    if (path == null || path.isEmpty) return '';
    return '$_imageBaseUrl/$size$path';
  }
  
  static Future<List<Map<String, dynamic>>> getTrending({
    String mediaType = 'all',
    String timeWindow = 'day',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trending/$mediaType/$timeWindow?api_key=$_apiKey'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        // Transform the data to match our UI needs
        return results.map((item) {
          final mediaType = item['media_type'] ?? (item['first_air_date'] != null ? 'tv' : 'movie');
          return {
            'id': item['id'],
            'title': item['title'] ?? item['name'] ?? 'Unknown',
            'backdrop': getImageUrl(item['backdrop_path']),
            'poster': getImageUrl(item['poster_path'], size: 'w500'),
            'rating': (item['vote_average'] ?? 0).toDouble(),
            'overview': item['overview'] ?? '',
            'releaseDate': item['release_date'] ?? item['first_air_date'],
            'mediaType': mediaType,
            'tmdbId': item['id'],
            // Mock data for now - would need additional API calls
            'watchingNow': (item['popularity'] ?? 0).toInt(),
            'inLibrary': false,
          };
        }).toList();
      }
      
      throw Exception('Failed to load trending: ${response.statusCode}');
    } catch (e) {
      print('TMDB API Error: $e');
      // Return mock data as fallback
      return _getMockData();
    }
  }
  
  static List<Map<String, dynamic>> _getMockData() {
    return [
      {
        'title': 'Moana 2',
        'backdrop': 'https://image.tmdb.org/t/p/original/tElnmtQ6yz1PjN1kePNl8yMSb59.jpg',
        'rating': 7.2,
        'watchingNow': 88,
        'inLibrary': true,
        'tmdbId': 1241982,
        'mediaType': 'movie',
      },
      {
        'title': 'Kaiju No. 8',
        'backdrop': 'https://image.tmdb.org/t/p/original/geCRueV3ElhSIqJGJRfBdbiLRAp.jpg',
        'rating': 8.6,
        'watchingNow': 107,
        'inLibrary': false,
        'tmdbId': 226411,
        'mediaType': 'tv',
      },
      {
        'title': 'Wicked',
        'backdrop': 'https://image.tmdb.org/t/p/original/c7Oft5UtMtfzS1w9YQbKnjQXSMw.jpg',
        'rating': 8.1,
        'watchingNow': 234,
        'inLibrary': true,
        'tmdbId': 402431,
        'mediaType': 'movie',
      },
    ];
  }
}