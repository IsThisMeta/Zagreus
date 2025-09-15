import 'dart:convert';
import 'package:http/http.dart' as http;

class TraktApi {
  static const String _baseUrl = 'https://api.trakt.tv';
  static const String _clientId = '0f1d48eb94803507ca6622c41ed0f609995329bfd06fb17b1c1860da68a52ccb';
  static const String _apiVersion = '2';
  
  static Future<List<Map<String, dynamic>>> getAnticipatedShows({
    int page = 1,
    int limit = 40,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/shows/anticipated?page=$page&limit=$limit');
      
      final response = await http.get(
        url,
        headers: {
          'trakt-api-version': _apiVersion,
          'trakt-api-key': _clientId,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Transform Trakt data to match our UI format
        return data.map((item) {
          final show = item['show'] ?? {};
          final ids = show['ids'] ?? {};
          
          return {
            'id': ids['tmdb'] ?? ids['trakt'] ?? 0,
            'title': show['title'] ?? 'Unknown',
            'year': show['year'],
            'tmdbId': ids['tmdb'],
            'tvdbId': ids['tvdb'],
            'imdbId': ids['imdb'],
            'traktId': ids['trakt'],
            'slug': ids['slug'],
            'overview': show['overview'] ?? '',
            'rating': show['rating'] ?? 0.0,
            'votes': show['votes'] ?? 0,
            'comment_count': show['comment_count'] ?? 0,
            'first_aired': show['first_aired'],
            'airs': show['airs'],
            'runtime': show['runtime'],
            'certification': show['certification'],
            'network': show['network'],
            'country': show['country'],
            'updated_at': show['updated_at'],
            'trailer': show['trailer'],
            'homepage': show['homepage'],
            'status': show['status'],
            'language': show['language'],
            'genres': show['genres'] ?? [],
            'aired_episodes': show['aired_episodes'],
            // Anticipation specific data
            'list_count': item['list_count'] ?? 0,
            'mediaType': 'tv',
            'isAnticipated': true,
          };
        }).toList();
      }
      
      print('Trakt API error: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('Error fetching Trakt anticipated shows: $e');
      return [];
    }
  }
  
  static Future<List<Map<String, dynamic>>> getAnticipatedMovies({
    int page = 1,
    int limit = 40,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/movies/anticipated?page=$page&limit=$limit');
      
      final response = await http.get(
        url,
        headers: {
          'trakt-api-version': _apiVersion,
          'trakt-api-key': _clientId,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Transform Trakt data to match our UI format
        return data.map((item) {
          final movie = item['movie'] ?? {};
          final ids = movie['ids'] ?? {};
          
          return {
            'id': ids['tmdb'] ?? ids['trakt'] ?? 0,
            'title': movie['title'] ?? 'Unknown',
            'year': movie['year'],
            'tmdbId': ids['tmdb'],
            'imdbId': ids['imdb'],
            'traktId': ids['trakt'],
            'slug': ids['slug'],
            'overview': movie['overview'] ?? '',
            'rating': movie['rating'] ?? 0.0,
            'votes': movie['votes'] ?? 0,
            'comment_count': movie['comment_count'] ?? 0,
            'released': movie['released'],
            'runtime': movie['runtime'],
            'certification': movie['certification'],
            'tagline': movie['tagline'],
            'country': movie['country'],
            'updated_at': movie['updated_at'],
            'trailer': movie['trailer'],
            'homepage': movie['homepage'],
            'language': movie['language'],
            'available_translations': movie['available_translations'] ?? [],
            'genres': movie['genres'] ?? [],
            // Anticipation specific data
            'list_count': item['list_count'] ?? 0,
            'mediaType': 'movie',
            'isAnticipated': true,
          };
        }).toList();
      }
      
      print('Trakt API error: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('Error fetching Trakt anticipated movies: $e');
      return [];
    }
  }
  
  static Future<List<Map<String, dynamic>>> getTrendingShows({
    int page = 1,
    int limit = 40,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/shows/trending?page=$page&limit=$limit');
      
      final response = await http.get(
        url,
        headers: {
          'trakt-api-version': _apiVersion,
          'trakt-api-key': _clientId,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Transform Trakt data to match our UI format
        return data.map((item) {
          final show = item['show'] ?? {};
          final ids = show['ids'] ?? {};
          
          return {
            'id': ids['tmdb'] ?? ids['trakt'] ?? 0,
            'title': show['title'] ?? 'Unknown',
            'year': show['year'],
            'tmdbId': ids['tmdb'],
            'tvdbId': ids['tvdb'],
            'imdbId': ids['imdb'],
            'traktId': ids['trakt'],
            'slug': ids['slug'],
            'overview': show['overview'] ?? '',
            'rating': show['rating'] ?? 0.0,
            'votes': show['votes'] ?? 0,
            'watchers': item['watchers'] ?? 0,
            'mediaType': 'tv',
            'isTrending': true,
          };
        }).toList();
      }
      
      print('Trakt API error: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('Error fetching Trakt trending shows: $e');
      return [];
    }
  }
  
  static Future<List<Map<String, dynamic>>> getPopularShows({
    int page = 1,
    int limit = 40,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/shows/popular?page=$page&limit=$limit');
      
      final response = await http.get(
        url,
        headers: {
          'trakt-api-version': _apiVersion,
          'trakt-api-key': _clientId,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Transform Trakt data to match our UI format
        return data.map((show) {
          final ids = show['ids'] ?? {};
          
          return {
            'id': ids['tmdb'] ?? ids['trakt'] ?? 0,
            'title': show['title'] ?? 'Unknown',
            'year': show['year'],
            'tmdbId': ids['tmdb'],
            'tvdbId': ids['tvdb'],
            'imdbId': ids['imdb'],
            'traktId': ids['trakt'],
            'slug': ids['slug'],
            'overview': show['overview'] ?? '',
            'rating': show['rating'] ?? 0.0,
            'votes': show['votes'] ?? 0,
            'mediaType': 'tv',
            'isPopular': true,
          };
        }).toList();
      }
      
      print('Trakt API error: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('Error fetching Trakt popular shows: $e');
      return [];
    }
  }
}