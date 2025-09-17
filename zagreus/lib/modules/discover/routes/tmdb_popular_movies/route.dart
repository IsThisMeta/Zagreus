import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

class TMDBPopularMoviesRoute extends StatefulWidget {
  final List<Map<String, dynamic>>? initialData;

  const TMDBPopularMoviesRoute({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<TMDBPopularMoviesRoute> createState() => _State();
}

class _State extends State<TMDBPopularMoviesRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      // Use the provided initial data
      _movies = widget.initialData!;
      _isLoading = false;
    } else {
      // Load data from API
      _loadPopularMovies();
    }

    // Add scroll listener for pagination
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMorePages) {
        _loadMoreMovies();
      }
    }
  }

  Future<void> _loadPopularMovies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get user's region from locale
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';

      final movies = await TMDBApi.getPopularMovies(page: 1, region: region);

      // Check against Radarr library if available
      final radarrState = context.read<RadarrState>();
      if (radarrState.enabled && radarrState.api != null) {
        try {
          radarrState.fetchMovies();
          final radarrMovies = await radarrState.movies!;

          for (final movie in movies) {
            final tmdbId = movie['tmdbId'] as int?;
            final title = movie['title'] as String;

            // Check if this movie is in Radarr library
            final inLibrary = radarrMovies.any((radarrMovie) {
              if (tmdbId != null && radarrMovie.tmdbId == tmdbId) {
                return true;
              }
              return radarrMovie.title?.toLowerCase() == title.toLowerCase();
            });
            movie['inLibrary'] = inLibrary;

            if (inLibrary) {
              final radarrMovie = radarrMovies.firstWhere(
                (m) =>
                    (tmdbId != null && m.tmdbId == tmdbId) ||
                    m.title?.toLowerCase() == title.toLowerCase(),
              );
              movie['serviceItemId'] = radarrMovie.id;
            }
          }
        } catch (e) {
          print('Failed to check Radarr library: $e');
        }
      }

      setState(() {
        _movies = movies;
        _isLoading = false;
        _currentPage = 1;
        _hasMorePages = movies.isNotEmpty;
      });
    } catch (error, stack) {
      ZagLogger().error('Failed to load popular movies', error, stack);
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';

      final nextPage = _currentPage + 1;
      final movies =
          await TMDBApi.getPopularMovies(page: nextPage, region: region);

      // Check against Radarr library if available
      final radarrState = context.read<RadarrState>();
      if (radarrState.enabled && radarrState.api != null) {
        try {
          final radarrMovies = await radarrState.movies!;

          for (final movie in movies) {
            final tmdbId = movie['tmdbId'] as int?;
            final title = movie['title'] as String;

            final inLibrary = radarrMovies.any((radarrMovie) {
              if (tmdbId != null && radarrMovie.tmdbId == tmdbId) {
                return true;
              }
              return radarrMovie.title?.toLowerCase() == title.toLowerCase();
            });
            movie['inLibrary'] = inLibrary;

            if (inLibrary) {
              final radarrMovie = radarrMovies.firstWhere(
                (m) =>
                    (tmdbId != null && m.tmdbId == tmdbId) ||
                    m.title?.toLowerCase() == title.toLowerCase(),
              );
              movie['serviceItemId'] = radarrMovie.id;
            }
          }
        } catch (e) {
          print('Failed to check Radarr library: $e');
        }
      }

      setState(() {
        _movies.addAll(movies);
        _currentPage = nextPage;
        _hasMorePages = movies.isNotEmpty;
        _isLoadingMore = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingMore = false;
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
      title: 'Popular Movies',
      actions: [
        IconButton(
          icon: Icon(ZagIcons.REFRESH),
          onPressed: _loadPopularMovies,
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
              'Error Loading Popular Movies',
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
              onPressed: _loadPopularMovies,
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
              'No Popular Movies Found',
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
      onRefresh: _loadPopularMovies,
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _movies.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _movies.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _movieTile(_movies[index]);
        },
      ),
    );
  }

  Widget _movieTile(Map<String, dynamic> movie) {
    final bool inLibrary = movie['inLibrary'] ?? false;
    final int? serviceItemId = movie['serviceItemId'] as int?;
    final int? tmdbId = movie['tmdbId'] as int?;

    return GestureDetector(
      onTap: () => _handleMovieTap(
        inLibrary: inLibrary,
        serviceItemId: serviceItemId,
        tmdbId: tmdbId,
        title: movie['title'] as String?,
      ),
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
              _buildPosterImage(movie),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
              ),
              // Library indicator
              // Library indicator - bottom right
              if (inLibrary)
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEC333), // Radarr yellow
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              // Rating badge - bottom left
              if (movie['rating'] != null && movie['rating'] > 0)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          (movie['rating'] ?? 0.0).toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterImage(Map<String, dynamic> movie) {
    final posterUrl = movie['poster'] as String?;

    if (posterUrl == null || posterUrl.isEmpty) {
      return _posterPlaceholder(movie);
    }

    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _posterPlaceholder(movie);
      },
    );
  }

  Widget _posterPlaceholder(Map<String, dynamic> movie) {
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
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                movie['title'] ?? 'Unknown',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMovieTap({
    required bool inLibrary,
    required int? serviceItemId,
    required int? tmdbId,
    required String? title,
  }) async {
    if (inLibrary && serviceItemId != null) {
      RadarrRoutes.MOVIE.go(
        params: {
          'movie': serviceItemId.toString(),
        },
      );
      return;
    }

    if (tmdbId == null) {
      showZagSnackBar(
        title: title ?? 'Movie',
        message: 'Missing TMDB identifier for this title.',
        type: ZagSnackbarType.ERROR,
      );
      return;
    }

    final radarrState = context.read<RadarrState>();
    if (!radarrState.enabled || radarrState.api == null) {
      showZagSnackBar(
        title: 'Radarr Unavailable',
        message: 'Connect Radarr to add movies from Discover.',
        type: ZagSnackbarType.INFO,
      );
      return;
    }

    bool loaderShown = false;
    void dismissLoader() {
      if (loaderShown && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        loaderShown = false;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: ZagLoader()),
    );
    loaderShown = true;

    try {
      final results = await radarrState.api!.movieLookup.get(
        term: 'tmdb:$tmdbId',
      );

      if (!mounted) {
        dismissLoader();
        return;
      }

      dismissLoader();

      if (results.isEmpty) {
        showZagSnackBar(
          title: title ?? 'Movie',
          message: 'Could not find TMDB ID $tmdbId in Radarr.',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      final radarrMovie = results.first;

      if (radarrMovie.id != null) {
        RadarrRoutes.MOVIE.go(
          params: {
            'movie': radarrMovie.id!.toString(),
          },
        );
        return;
      }

      RadarrRoutes.ADD_MOVIE_DETAILS.go(
        extra: radarrMovie,
        queryParams: {'isDiscovery': 'true'},
      );
    } catch (error, stack) {
      dismissLoader();
      if (!mounted) return;
      ZagLogger().error('Failed to open Radarr add movie flow', error, stack);
      showZagSnackBar(
        title: title ?? 'Movie',
        message: 'Something went wrong talking to Radarr.',
        type: ZagSnackbarType.ERROR,
      );
    }
  }
}
