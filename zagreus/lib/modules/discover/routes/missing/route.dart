import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

class DiscoverMissingRoute extends StatefulWidget {
  const DiscoverMissingRoute({Key? key}) : super(key: key);

  @override
  State<DiscoverMissingRoute> createState() => _State();
}

class _State extends State<DiscoverMissingRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<RadarrMovie> _movies = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadMissingMovies();
  }
  
  Future<void> _loadMissingMovies() async {
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
      
      // Fetch movies if not already cached
      if (radarrState.movies == null) {
        radarrState.fetchMovies();
      }
      
      // Get missing movies from state
      if (radarrState.missing == null) {
        setState(() {
          _error = 'Unable to fetch missing movies';
          _isLoading = false;
        });
        return;
      }
      
      final missingMovies = await radarrState.missing!;
      
      setState(() {
        _movies = missingMovies;
        _isLoading = false;
        if (_movies.isEmpty) {
          _error = 'All movies downloaded!';
        }
      });
      
    } catch (error, stack) {
      ZagLogger().error('Failed to load missing movies', error, stack);
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
      title: 'Missing Movies',
      actions: [
        IconButton(
          icon: Icon(ZagIcons.REFRESH),
          onPressed: _loadMissingMovies,
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
    
    if (_error != null && _error != 'All movies downloaded!') {
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
              'Error Loading Missing Movies',
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
              onPressed: _loadMissingMovies,
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
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'All Movies Downloaded!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No missing movies in your library',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadMissingMovies,
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _movies.length,
        itemBuilder: (context, index) => _movieTile(_movies[index]),
      ),
    );
  }
  
  Widget _movieTile(RadarrMovie movie) {
    return GestureDetector(
      onTap: () {
        // Navigate to movie details
        RadarrRoutes.MOVIE.go(
          params: {
            'movie': movie.id.toString(),
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade800,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster
              _buildPosterImage(context, movie),
              // Orange overlay for missing status
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.orange.withOpacity(0.1),
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // Missing indicator at top
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'MISSING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Title
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.title ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    if (movie.year != null)
                      Text(
                        movie.year.toString(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPosterImage(BuildContext context, RadarrMovie movie) {
    final posterUrl = context.read<RadarrState>().getPosterURL(movie.id);
    final headers = context.read<RadarrState>().headers;
    
    if (posterUrl == null) {
      return _posterPlaceholder(movie);
    }
    
    // Convert headers to Map<String, String>
    final stringHeaders = <String, String>{};
    headers.forEach((key, value) {
      stringHeaders[key.toString()] = value.toString();
    });
    
    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      headers: stringHeaders.isNotEmpty ? stringHeaders : null,
      errorBuilder: (context, error, stackTrace) {
        return _posterPlaceholder(movie);
      },
    );
  }
  
  Widget _posterPlaceholder(RadarrMovie movie) {
    return Container(
      color: Colors.grey.shade800,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_rounded,
              size: 40,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}