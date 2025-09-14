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
  
  // Multi-search across movies, TV shows, and people
  Future<List<Map<String, dynamic>>> searchMulti(String query, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/multi?api_key=$_apiKey&query=${Uri.encodeComponent(query)}&page=$page&include_adult=false'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        // Return raw results for the search UI to process
        return List<Map<String, dynamic>>.from(results);
      }
      
      throw Exception('Failed to search: ${response.statusCode}');
    } catch (e) {
      print('TMDB Search Error: $e');
      return [];
    }
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
  
  static Future<List<Map<String, dynamic>>> getPopularMovies({
    int page = 1,
    String? region,
  }) async {
    try {
      String url = '$_baseUrl/movie/popular?api_key=$_apiKey&page=$page';
      if (region != null) {
        url += '&region=$region';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        // Transform the data to match our UI needs
        return results.map((item) {
          return {
            'id': item['id'],
            'title': item['title'] ?? 'Unknown',
            'backdrop': getImageUrl(item['backdrop_path']),
            'poster': getImageUrl(item['poster_path'], size: 'w500'),
            'rating': (item['vote_average'] ?? 0).toDouble(),
            'overview': item['overview'] ?? '',
            'releaseDate': item['release_date'],
            'mediaType': 'movie',
            'tmdbId': item['id'],
            'popularity': item['popularity'] ?? 0,
            'inLibrary': false,
          };
        }).toList();
      }
      
      throw Exception('Failed to load popular movies: ${response.statusCode}');
    } catch (e) {
      print('TMDB API Error (Popular Movies): $e');
      // Return mock data as fallback
      return _getMockPopularMovies();
    }
  }
  
  static Future<List<Map<String, dynamic>>> getPopularPeople({
    int page = 1,
    String? region,
  }) async {
    try {
      String url = '$_baseUrl/person/popular?api_key=$_apiKey&page=$page';
      if (region != null) {
        url += '&language=en-$region';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        // Transform the data to match our UI needs
        return results.map((person) {
          return {
            'id': person['id'],
            'name': person['name'],
            'profilePath': person['profile_path'] != null 
                ? getImageUrl(person['profile_path'], size: 'w185')
                : null,
            'knownForDepartment': person['known_for_department'],
            'popularity': person['popularity'],
            'knownFor': (person['known_for'] as List?)?.map((item) {
              return {
                'id': item['id'],
                'title': item['title'] ?? item['name'] ?? 'Unknown',
                'poster': getImageUrl(item['poster_path'], size: 'w185'),
                'mediaType': item['media_type'],
              };
            }).toList() ?? [],
          };
        }).toList();
      }
      
      throw Exception('Failed to load popular people: ${response.statusCode}');
    } catch (e) {
      print('TMDB API Error (Popular People): $e');
      // Return mock data as fallback
      return _getMockPopularPeople();
    }
  }
  
  static List<Map<String, dynamic>> _getMockPopularPeople() {
    return [
      {
        'id': 1245,
        'name': 'Scarlett Johansson',
        'profilePath': 'https://image.tmdb.org/t/p/w185/6NsMbJXRlDZuDzatN2akFdGuTvx.jpg',
        'knownForDepartment': 'Acting',
        'popularity': 98.5,
      },
      {
        'id': 2888,
        'name': 'Will Smith',
        'profilePath': 'https://image.tmdb.org/t/p/w185/j1VdmftAir0hdeWKadDuIpfmWFd.jpg',
        'knownForDepartment': 'Acting',
        'popularity': 87.3,
      },
    ];
  }
  
  static List<Map<String, dynamic>> _getMockPopularMovies() {
    return [
      {
        'id': 939243,
        'title': 'Sonic the Hedgehog 3',
        'poster': 'https://image.tmdb.org/t/p/w500/d8Ryb8AunYAuycVKDp5HpdWPKgC.jpg',
        'rating': 7.8,
        'tmdbId': 939243,
        'mediaType': 'movie',
        'inLibrary': false,
      },
      {
        'id': 1184918,
        'title': 'The Wild Robot',
        'poster': 'https://image.tmdb.org/t/p/w500/wTnV3PCVW5O92JMrFvvrRcV39RU.jpg',
        'rating': 8.5,
        'tmdbId': 1184918,
        'mediaType': 'movie',
        'inLibrary': false,
      },
    ];
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