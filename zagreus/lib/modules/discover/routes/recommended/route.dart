import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

class DiscoverRecommendedRoute extends StatefulWidget {
  const DiscoverRecommendedRoute({Key? key}) : super(key: key);

  @override
  State<DiscoverRecommendedRoute> createState() => _State();
}

class _State extends State<DiscoverRecommendedRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<RadarrMovie> _movies = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadRecommendedMovies();
  }
  
  Future<void> _loadRecommendedMovies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final radarrState = context.read<RadarrState>();
      if (!radarrState.enabled) {
        setState(() {
          _error = 'Radarr is not enabled';
          _isLoading = false;
        });
        return;
      }
      
      final api = radarrState.api;
      if (api == null) {
        setState(() {
          _error = 'Radarr API is not configured';
          _isLoading = false;
        });
        return;
      }
      
      // Fetch recommended movies from Radarr's import lists
      // First, get all import lists
      final importLists = await api.importList.getAll();
      
      // Find import lists that are recommendations (like TMDB Popular, IMDB Top, etc)
      final recommendationLists = importLists.where((list) {
        return list.enabled == true && (
          list.name?.toLowerCase().contains('popular') == true ||
          list.name?.toLowerCase().contains('top') == true ||
          list.name?.toLowerCase().contains('trending') == true ||
          list.name?.toLowerCase().contains('recommend') == true
        );
      }).toList();
      
      // If no recommendation lists, try to get from all enabled lists
      if (recommendationLists.isEmpty) {
        recommendationLists.addAll(
          importLists.where((list) => list.enabled == true).take(3)
        );
      }
      
      // Fetch movies from import lists (Radarr's recommendations)
      final Set<int> tmdbIds = {};
      List<RadarrMovie> recommendedMovies = [];
      
      try {
        // Get all movies from import lists with recommendations
        recommendedMovies = await api.importList.getMovies(
          includeRecommendations: true,
        );
        
        // Remove duplicates by TMDB ID
        final uniqueMovies = <RadarrMovie>[];
        for (final movie in recommendedMovies) {
          if (movie.tmdbId != null && !tmdbIds.contains(movie.tmdbId)) {
            tmdbIds.add(movie.tmdbId!);
            uniqueMovies.add(movie);
          }
        }
        recommendedMovies = uniqueMovies;
      } catch (e) {
        ZagLogger().warning('Failed to fetch recommendations: $e');
      }
      
      // Sort by popularity or rating if available
      recommendedMovies.sort((a, b) {
        // Sort by year (newer first), then by title
        if (a.year != null && b.year != null) {
          final yearCompare = b.year!.compareTo(a.year!);
          if (yearCompare != 0) return yearCompare;
        }
        final aTitle = a.title ?? '';
        final bTitle = b.title ?? '';
        return aTitle.compareTo(bTitle);
      });
      
      // Limit to reasonable number for display
      final displayMovies = recommendedMovies.take(50).toList();
      
      setState(() {
        _movies = displayMovies;
        _isLoading = false;
        if (_movies.isEmpty) {
          _error = 'No recommendations found. Make sure you have import lists configured in Radarr.';
        }
      });
      
    } catch (error, stack) {
      ZagLogger().error('Failed to load recommended movies', error, stack);
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }
  
  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'Recommended Movies',
      actions: [
        IconButton(
          icon: Icon(ZagIcons.REFRESH),
          onPressed: _loadRecommendedMovies,
        ),
      ],
    );
  }
  
  Widget _body() {
    if (_isLoading) {
      return Center(
        child: ZagLoader(),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Error Loading Recommendations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecommendedMovies,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Recommendations Available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadRecommendedMovies,
      child: GridView.builder(
        controller: scrollController,
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2/3,
        ),
        itemCount: _movies.length,
        itemBuilder: (context, index) => _movieTile(_movies[index]),
      ),
    );
  }
  
  Widget _movieTile(RadarrMovie movie) {
    return InkWell(
      onTap: () {
        // Navigate to movie details if in library
        if (movie.id != null) {
          RadarrRoutes.MOVIE.go(
            params: {
              'movie': movie.id.toString(),
            },
          );
        } else if (movie.tmdbId != null) {
          // Navigate to add movie with TMDB ID
          RadarrRoutes.ADD_MOVIE.go(
            params: {
              'query': 'tmdb:${movie.tmdbId}',
            },
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade900,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Movie poster
            if (movie.id != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ZagNetworkImage(
                  context: context,
                  url: context.read<RadarrState>().getPosterURL(movie.id),
                  height: double.infinity,
                  width: double.infinity,
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade800,
                ),
                child: Center(
                  child: Icon(
                    Icons.movie,
                    size: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: [0.6, 1.0],
                ),
              ),
            ),
            
            // Movie info
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (movie.year != null)
                    Text(
                      movie.year.toString(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            
            // Status indicator
            if (movie.hasFile == false)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'MISSING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}