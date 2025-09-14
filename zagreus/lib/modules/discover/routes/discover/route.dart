import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/router/routes/discover.dart';
import 'package:zagreus/router/routes/search.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';

class DiscoverHomeRoute extends StatefulWidget {
  const DiscoverHomeRoute({Key? key}) : super(key: key);

  @override
  State<DiscoverHomeRoute> createState() => _State();
}

class _State extends State<DiscoverHomeRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ZagPageController _pageController;
  int _currentPageIndex = 0;
  
  List<RadarrMovie> _recentlyDownloaded = [];
  List<dynamic> _recentlyDownloadedShows = []; // Sonarr episodes
  List<RadarrMovie> _recommendedMovies = [];
  List<RadarrMovie> _missingMovies = [];
  List<Map<String, dynamic>> _popularMovies = [];
  bool _isLoading = true;
  String? _error;
  
  // Hero carousel state
  PageController _heroPageController = PageController();
  int _currentHeroIndex = 0;
  String _trendingTimeWindow = 'day'; // 'day' or 'week'
  List<Map<String, dynamic>> _trendingItems = [];
  Timer? _autoScrollTimer;
  
  @override
  void initState() {
    super.initState();
    _pageController = ZagPageController(initialPage: 0);
    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        setState(() {
          _currentPageIndex = _pageController.page!.round();
        });
      }
    });
    _loadRecentlyDownloaded();
    _loadRecentlyDownloadedShows();
    _loadRecommendedMovies();
    _loadMissingMovies();
    // Don't load popular movies here - will do it in didChangeDependencies
    _loadMockTrendingData();
    _startAutoScroll();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load popular movies here where we can access Localizations
    _loadPopularMovies();
  }
  
  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _heroPageController.dispose();
    _pageController.dispose();
    super.dispose();
  }
  
  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_trendingItems.isNotEmpty) {
        final nextIndex = (_currentHeroIndex + 1) % _trendingItems.length;
        _heroPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }
  
  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }
  
  void _restartAutoScroll() {
    _stopAutoScroll();
    _startAutoScroll();
  }
  
  void _loadMockTrendingData() {
    _loadTrendingData();
  }
  
  Future<void> _loadTrendingData() async {
    try {
      final items = await TMDBApi.getTrending(
        mediaType: 'all', // Can be 'movie', 'tv', or 'all'
        timeWindow: _trendingTimeWindow,
      );
      
      // Check against Radarr library if available
      if (mounted) {
        final radarrState = context.read<RadarrState>();
        if (radarrState.enabled && radarrState.movies != null) {
          final movies = await radarrState.movies!;
          for (final item in items) {
            if (item['mediaType'] == 'movie') {
              final tmdbId = item['tmdbId'] as int;
              item['inLibrary'] = movies.any((m) => m.tmdbId == tmdbId);
            }
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _trendingItems = items;
        });
      }
    } catch (e) {
      print('Failed to load trending: $e');
      // Falls back to mock data in the API
    }
  }
  
  Future<void> _loadRecentlyDownloaded() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Check if Radarr is enabled first
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
      
      // Fetch history
      final history = await api.history.get(
        pageSize: 50,
        sortDirection: RadarrSortDirection.DESCENDING,
        sortKey: RadarrHistorySortKey.DATE,
      );
      
      // Filter only downloaded items and get unique movie IDs
      final downloadedRecords = history.records?.where((record) {
        return record.eventType == RadarrEventType.DOWNLOAD_FOLDER_IMPORTED;
      }).toList() ?? [];
      
      // Get unique movie IDs from history
      final movieIds = <int>{};
      for (final record in downloadedRecords) {
        if (record.movieId != null) {
          movieIds.add(record.movieId!);
        }
      }
      
      // Fetch all movies if not already cached
      if (radarrState.movies == null) {
        radarrState.fetchMovies();
      }
      
      // Wait for movies to load
      final allMovies = await radarrState.movies!;
      
      // Filter movies that are in the downloaded history
      final downloadedMovies = <RadarrMovie>[];
      for (final movieId in movieIds.take(10)) {
        final movie = allMovies.firstWhere(
          (m) => m.id == movieId,
          orElse: () => RadarrMovie(),
        );
        if (movie.id != null) {
          downloadedMovies.add(movie);
        }
      }
      
      setState(() {
        _recentlyDownloaded = downloadedMovies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadRecommendedMovies() async {
    try {
      final radarrState = context.read<RadarrState>();
      if (!radarrState.enabled) {
        return;
      }
      
      final api = radarrState.api;
      if (api == null) {
        return;
      }
      
      // Fetch recommended movies from import lists
      final recommendedMovies = await api.importList.getMovies(
        includeRecommendations: true,
      );
      
      // Remove duplicates and limit
      final Set<int> tmdbIds = {};
      final uniqueMovies = <RadarrMovie>[];
      for (final movie in recommendedMovies) {
        if (movie.tmdbId != null && !tmdbIds.contains(movie.tmdbId)) {
          tmdbIds.add(movie.tmdbId!);
          uniqueMovies.add(movie);
        }
      }
      
      setState(() {
        _recommendedMovies = uniqueMovies.take(10).toList();
      });
    } catch (e) {
      // Silently fail - recommendations are optional
      print('Failed to load recommendations: $e');
    }
  }
  
  Future<void> _loadMissingMovies() async {
    try {
      final radarrState = context.read<RadarrState>();
      if (!radarrState.enabled) {
        return;
      }
      
      // Fetch movies if not already cached
      if (radarrState.movies == null) {
        radarrState.fetchMovies();
      }
      
      // Get missing movies from state
      if (radarrState.missing != null) {
        final missingMovies = await radarrState.missing!;
        setState(() {
          _missingMovies = missingMovies.take(10).toList();
        });
      }
    } catch (e) {
      // Silently fail - missing movies are optional
      print('Failed to load missing movies: $e');
    }
  }
  
  Future<void> _loadPopularMovies() async {
    print('🎬 Loading popular movies...');
    try {
      // Get user's region from locale
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';
      print('🎬 Using region: $region');
      
      final movies = await TMDBApi.getPopularMovies(region: region);
      print('🎬 Got ${movies.length} popular movies from TMDB');
      
      // Check against Radarr library if available
      final radarrState = context.read<RadarrState>();
      if (radarrState.enabled && radarrState.movies != null) {
        final radarrMovies = await radarrState.movies!;
        for (final movie in movies) {
          final tmdbId = movie['tmdbId'] as int;
          movie['inLibrary'] = radarrMovies.any((m) => m.tmdbId == tmdbId);
        }
      }
      
      if (mounted) {
        setState(() {
          _popularMovies = movies.take(10).toList(); // Limit to 10 for the section
        });
        print('🎬 Set ${_popularMovies.length} popular movies in state');
      }
    } catch (e) {
      print('❌ Error loading popular movies: $e');
    }
  }
  
  Future<void> _loadRecentlyDownloadedShows() async {
    // For now, we'll use mock data since Sonarr integration isn't set up yet
    // In a real implementation, this would fetch from SonarrState similar to RadarrState
    setState(() {
      _recentlyDownloadedShows = [
        {
          'seriesTitle': 'The Paper (2025)',
          'episodeTitle': 'The Ohio Journalism Awards',
          'seasonNumber': 1,
          'episodeNumber': 10,
          'network': 'Downloaded',
          'thumbnail': 'https://image.tmdb.org/t/p/w300/vLZK0kNRE5lqVVyeuqPS1XcMYqR.jpg',
        },
        {
          'seriesTitle': 'The Paper (2025)',
          'episodeTitle': 'Matching Ponchos',
          'seasonNumber': 1,
          'episodeNumber': 9,
          'network': 'Downloaded',
          'thumbnail': 'https://image.tmdb.org/t/p/w300/vLZK0kNRE5lqVVyeuqPS1XcMYqR.jpg',
        },
        {
          'seriesTitle': 'The Paper (2025)',
          'episodeTitle': 'Church and State',
          'seasonNumber': 1,
          'episodeNumber': 8,
          'network': 'Downloaded',
          'thumbnail': 'https://image.tmdb.org/t/p/w300/vLZK0kNRE5lqVVyeuqPS1XcMYqR.jpg',
        },
      ];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.DISCOVER,
      drawer: ZagDrawer(page: ZagModule.DISCOVER.key),
      appBar: ZagAppBar(
        title: 'Discover',
        useDrawer: true,
        actions: _currentPageIndex != 3 ? [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                _appBarToggleButton('Today', 'day'),
                const SizedBox(width: 8),
                _appBarToggleButton('This Week', 'week'),
              ],
            ),
          ),
        ] : null,
      ),
      body: _body(),
      bottomNavigationBar: _DiscoverNavigationBar(
        pageController: _pageController,
      ),
    );
  }
  
  Widget _body() {
    return ZagPageView(
      controller: _pageController,
      children: [
        _moviesPage(),
        _tvShowsPage(),
        _calendarPage(),
        _searchPage(),
      ],
    );
  }
  
  Widget _moviesPage() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF6688FF)),
        ),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load recently downloaded',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey
                    : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecentlyDownloaded,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6688FF),
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadRecentlyDownloaded,
      child: ListView(
        controller: _DiscoverNavigationBar.scrollControllers[0],
        padding: EdgeInsets.zero,
        children: [
          // Hero carousel
          _heroCarousel(),
          // Content sections
          if (_recentlyDownloaded.isNotEmpty) _recentlyDownloadedSection(),
          const SizedBox(height: 12),
          _recommendedMoviesSection(),
          const SizedBox(height: 12),
          if (_missingMovies.isNotEmpty) _missingMoviesSection(),
          const SizedBox(height: 12),
          _popularMoviesSection(), // Always show section, even while loading
          const SizedBox(height: 12),
        ],
      ),
    );
  }
  
  Widget _tvShowsPage() {
    return RefreshIndicator(
      onRefresh: _loadRecentlyDownloadedShows,
      child: ListView(
        controller: _DiscoverNavigationBar.scrollControllers[1],
        padding: EdgeInsets.zero,
        children: [
          // Hero carousel (could be TV shows specific)
          _heroCarousel(),
          // TV shows sections
          if (_recentlyDownloadedShows.isNotEmpty) _recentlyDownloadedShowsSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _calendarPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 80,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.3)
                : Colors.black.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Release calendar will be available here',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.black.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
  
  // Search state
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchDebounce;

  Widget _searchPage() {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Search movies, TV shows, and people...',
              hintStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.3)
                    : Colors.black.withOpacity(0.3),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.5),
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchResults.clear();
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ZagColours.accent,
                  width: 2,
                ),
              ),
            ),
            onChanged: (query) {
              // Debounce search
              _searchDebounce?.cancel();
              if (query.isEmpty) {
                setState(() {
                  _searchResults.clear();
                });
                return;
              }
              _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                _performSearch(query);
              });
            },
          ),
        ),
        // Search results
        Expanded(
          child: _isSearching
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(ZagColours.accent),
                  ),
                )
              : _searchResults.isEmpty
                  ? _searchController.text.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_rounded,
                                size: 60,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.black.withOpacity(0.2),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Search for movies, TV shows, and people',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.4)
                                      : Colors.black.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 60,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.black.withOpacity(0.2),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No results found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.4)
                                      : Colors.black.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        )
                  : _buildSearchResults(),
        ),
      ],
    );
  }
  
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isSearching = true;
    });
    
    try {
      print('🔍 Searching for: $query');
      final tmdbApi = TMDBApi();
      final results = await tmdbApi.searchMulti(query);
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
      
      print('🔍 Found ${results.length} results');
    } catch (e) {
      print('❌ Search error: $e');
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      showZagSnackBar(
        title: 'Search Error',
        message: 'Failed to search. Please try again.',
        type: ZagSnackbarType.ERROR,
      );
    }
  }
  
  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final mediaType = item['media_type'] as String?;
        final title = item['title'] ?? item['name'] ?? 'Unknown';
        final overview = item['overview'] ?? '';
        final posterPath = item['poster_path'] as String?;
        final profilePath = item['profile_path'] as String?;
        final releaseDate = item['release_date'] ?? item['first_air_date'] ?? '';
        final voteAverage = (item['vote_average'] ?? 0).toDouble();
        
        // Get appropriate image path
        String? imagePath;
        if (mediaType == 'person') {
          imagePath = profilePath;
        } else {
          imagePath = posterPath;
        }
        
        final imageUrl = imagePath != null 
            ? 'https://image.tmdb.org/t/p/w185$imagePath'
            : null;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _handleSearchResultTap(item);
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster/Profile image
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade800,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _searchResultPlaceholder(mediaType);
                              },
                            )
                          : _searchResultPlaceholder(mediaType),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Media type badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getMediaTypeColor(mediaType),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getMediaTypeLabel(mediaType),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Title
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (releaseDate.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            releaseDate.split('-').first,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ],
                        if (mediaType != 'person' && voteAverage > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.yellow,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                voteAverage.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.black.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (overview.isNotEmpty && mediaType != 'person') ...[
                          const SizedBox(height: 6),
                          Text(
                            overview,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.6)
                                  : Colors.black.withOpacity(0.6),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _searchResultPlaceholder(String? mediaType) {
    IconData icon;
    if (mediaType == 'person') {
      icon = Icons.person_rounded;
    } else if (mediaType == 'tv') {
      icon = Icons.tv_rounded;
    } else {
      icon = Icons.movie_rounded;
    }
    
    return Center(
      child: Icon(
        icon,
        size: 40,
        color: Colors.grey.shade600,
      ),
    );
  }
  
  Color _getMediaTypeColor(String? mediaType) {
    switch (mediaType) {
      case 'movie':
        return Colors.blue;
      case 'tv':
        return Colors.green;
      case 'person':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  String _getMediaTypeLabel(String? mediaType) {
    switch (mediaType) {
      case 'movie':
        return 'MOVIE';
      case 'tv':
        return 'TV SHOW';
      case 'person':
        return 'PERSON';
      default:
        return 'UNKNOWN';
    }
  }
  
  void _handleSearchResultTap(Map<String, dynamic> item) {
    final mediaType = item['media_type'] as String?;
    final tmdbId = item['id'] as int;
    final title = item['title'] ?? item['name'] ?? 'Unknown';
    
    if (mediaType == 'movie') {
      // Try to find in Radarr first
      final radarrState = context.read<RadarrState>();
      if (radarrState.enabled && radarrState.movies != null) {
        radarrState.movies!.then((movies) {
          final movie = movies.firstWhere(
            (m) => m.tmdbId == tmdbId,
            orElse: () => RadarrMovie(),
          );
          
          if (movie.id != null) {
            // Movie is in library, navigate to details
            RadarrRoutes.MOVIE.go(
              params: {
                'movie': movie.id.toString(),
              },
            );
          } else {
            // Movie not in library, navigate to add movie with TMDB ID
            RadarrRoutes.ADD_MOVIE.go(
              queryParams: {
                'query': 'tmdb:$tmdbId',
              },
            );
          }
        });
      }
    } else if (mediaType == 'tv') {
      // TV show handling would go here with Sonarr
      showZagSnackBar(
        title: title,
        message: 'TV show support coming soon',
        type: ZagSnackbarType.INFO,
      );
    } else if (mediaType == 'person') {
      // Person details
      showZagSnackBar(
        title: title,
        message: 'Person details coming soon',
        type: ZagSnackbarType.INFO,
      );
    }
  }
  
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_rounded,
            size: 100,
            color: const Color(0xFF6688FF),
          ),
          const SizedBox(height: 20),
          Text(
            'Discover',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6688FF),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'No recently downloaded movies',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _heroCarousel() {
    return SizedBox(
      height: 450,
      child: Stack(
        children: [
          GestureDetector(
            onPanDown: (_) => _stopAutoScroll(),
            onPanCancel: () => _restartAutoScroll(),
            onPanEnd: (_) => _restartAutoScroll(),
            child: PageView.builder(
              controller: _heroPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentHeroIndex = index;
                });
              },
              itemCount: _trendingItems.length,
              itemBuilder: (context, index) {
                final item = _trendingItems[index];
                return GestureDetector(
                onTap: () => _handleHeroTap(item),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Backdrop image
                    Image.network(
                      item['backdrop'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade800,
                          child: Center(
                            child: Icon(
                              Icons.movie_rounded,
                              size: 60,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        );
                      },
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  // Content
                  Positioned(
                    bottom: 40,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // In library badge
                        if (item['inLibrary'] as bool)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_circle_fill,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'In library',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Rating and watching
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (item['rating'] as num) > 0 
                                  ? (item['rating'] as num).toStringAsFixed(1)
                                  : 'N/A',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '• ${item['watchingNow']} watching now',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                ),
              );
            },
            ),
          ),
          // Page indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _trendingItems.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentHeroIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentHeroIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _timeWindowToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _toggleButton('Today', 'day'),
          const SizedBox(width: 12),
          _toggleButton('This Week', 'week'),
        ],
      ),
    );
  }
  
  void _handleHeroTap(Map<String, dynamic> item) async {
    final mediaType = item['mediaType'] as String;
    final tmdbId = item['tmdbId'] as int;
    
    if (mediaType == 'movie') {
      // Check if movie is in Radarr library
      final radarrState = context.read<RadarrState>();
      if (radarrState.enabled && radarrState.movies != null) {
        final movies = await radarrState.movies!;
        final movie = movies.firstWhere(
          (m) => m.tmdbId == tmdbId,
          orElse: () => RadarrMovie(),
        );
        
        if (movie.id != null) {
          // Movie is in library, navigate to details
          RadarrRoutes.MOVIE.go(
            params: {
              'movie': movie.id.toString(),
            },
          );
        } else {
          // Movie not in library, navigate to add movie with TMDB ID
          // Radarr accepts tmdb: prefix for TMDB ID lookups
          RadarrRoutes.ADD_MOVIE.go(
            queryParams: {
              'query': 'tmdb:$tmdbId',
            },
          );
        }
      }
    } else if (mediaType == 'tv') {
      // For TV shows, we'd need similar logic with Sonarr
      showZagSnackBar(
        title: item['title'] as String,
        message: 'TV show support coming soon',
        type: ZagSnackbarType.INFO,
      );
    }
  }
  
  Widget _appBarToggleButton(String label, String value) {
    final isSelected = _trendingTimeWindow == value;
    
    return TextButton(
      onPressed: () {
        setState(() {
          _trendingTimeWindow = value;
          _currentHeroIndex = 0;
        });
        _heroPageController.jumpToPage(0);
        _loadTrendingData();
        _restartAutoScroll();
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
        backgroundColor: isSelected 
            ? (Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05))
            : Colors.transparent,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87)
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54),
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _toggleButton(String label, String value) {
    final isSelected = _trendingTimeWindow == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _trendingTimeWindow = value;
          _currentHeroIndex = 0;
        });
        _heroPageController.jumpToPage(0);
        _loadTrendingData();
        _restartAutoScroll();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.grey : Colors.grey.shade600),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.grey : Colors.grey.shade600),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
  
  Widget _recommendedMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
            onTap: () {
              DiscoverRoutes.RECOMMENDED.go();
            },
            child: Row(
              children: [
                Icon(
                  ZagIcons.RADARR,
                  color: const Color(0xFFFEC333),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Radarr',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFEC333),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Recommended',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black).withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        // Movie list or placeholder
        _recommendedMovies.isNotEmpty
            ? SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _recommendedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _recommendedMovies[index];
                    return _movieCard(movie);
                  },
                ),
              )
            : Container(
                height: 180,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Tap to view recommended movies',
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black).withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
  
  Widget _missingMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
            onTap: () {
              DiscoverRoutes.MISSING.go();
            },
            child: Row(
              children: [
                Icon(
                  ZagIcons.RADARR,
                  color: const Color(0xFFFEC333),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Radarr',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFEC333),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Missing',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black).withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        // Movie list
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _missingMovies.length,
            itemBuilder: (context, index) {
              final movie = _missingMovies[index];
              return _missingMovieCard(movie);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _popularMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: const Color(0xFF6688FF),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'TMDB',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6688FF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Popular Movies',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Movie list or loading placeholder
        _popularMovies.isNotEmpty
            ? SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _popularMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _popularMovies[index];
                    return _popularMovieCard(movie);
                  },
                ),
              )
            : Container(
                height: 180,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Loading popular movies...',
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black).withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
  
  Widget _popularMovieCard(Map<String, dynamic> movie) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Could navigate to a detail view or add to Radarr
          _handlePopularMovieTap(movie);
        },
        child: Container(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade800,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie['poster'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.movie_rounded,
                              size: 40,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // In library badge
                  if (movie['inLibrary'] == true)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  // Rating badge
                  if (movie['rating'] != null && movie['rating'] > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.yellow,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              (movie['rating'] as num).toStringAsFixed(1),
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
              const SizedBox(height: 8),
              // Movie title
              Text(
                movie['title'] ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _handlePopularMovieTap(Map<String, dynamic> movie) {
    // For now, just show a snackbar
    // Could implement adding to Radarr or showing details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${movie['title']} - TMDB ID: ${movie['tmdbId']}'),
        action: movie['inLibrary'] != true
            ? SnackBarAction(
                label: 'Add to Radarr',
                onPressed: () {
                  // Implement add to Radarr functionality
                },
              )
            : null,
      ),
    );
  }
  
  Widget _missingMovieCard(RadarrMovie movie) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Navigate to movie detail
          RadarrRoutes.MOVIE.go(
            params: {
              'movie': movie.id.toString(),
            },
          );
        },
        child: Container(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster with missing indicator
              Stack(
                children: [
                  // Simplified poster container to match regular movie cards
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 180,
                      width: 140,
                      color: Colors.grey.shade800,
                      child: _buildPosterImage(context, movie),
                    ),
                  ),
                  // Missing badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'MISSING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Movie title
              Text(
                movie.title ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _recentlyDownloadedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
            onTap: () {
              DiscoverRoutes.RECENTLY_DOWNLOADED.go();
            },
            child: Row(
              children: [
                Icon(
                  ZagIcons.RADARR,
                  color: const Color(0xFFFEC333),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Radarr',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFEC333),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Recently Downloaded',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        // Movie list
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recentlyDownloaded.length,
            itemBuilder: (context, index) {
              final item = _recentlyDownloaded[index];
              return _movieCard(item);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _movieCard(RadarrMovie movie) {
    
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Navigate to movie detail
          RadarrRoutes.MOVIE.go(
            params: {
              'movie': movie.id.toString(),
            },
          );
        },
        child: Container(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster
              Container(
                height: 180,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade800,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildPosterImage(context, movie),
                ),
              ),
              const SizedBox(height: 8),
              // Movie title
              Text(
                movie.title ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPosterImage(BuildContext context, RadarrMovie movie) {
    // Try to get poster URL - either from movie ID (if in library) or from images array
    String? posterUrl;
    
    if (movie.id != null) {
      // Movie is in library, use standard poster URL
      posterUrl = context.read<RadarrState>().getPosterURL(movie.id);
    } else if (movie.images?.isNotEmpty == true) {
      // Movie not in library but has images, extract poster URL from images array
      final posterImage = movie.images!.firstWhere(
        (img) => img.coverType?.toLowerCase().contains('poster') == true,
        orElse: () => movie.images!.first,
      );
      
      // Use remoteUrl if available, otherwise use url
      posterUrl = posterImage.remoteUrl ?? posterImage.url;
    }
    
    if (posterUrl == null) {
      return _posterPlaceholder(movie);
    }
    
    final headers = context.read<RadarrState>().headers;
    
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
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                movie.title ?? 'Unknown',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
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
  
  Widget _recentlyDownloadedShowsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                ZagIcons.SONARR,
                color: const Color(0xFF35C5F4),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'From Sonarr',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF35C5F4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Recently Downloaded',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
                size: 24,
              ),
            ],
          ),
        ),
        // TV show list with thin cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _recentlyDownloadedShows.map((episode) {
              return _tvShowCard(episode);
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _tvShowCard(Map<String, dynamic> episode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // TODO: Navigate to episode details
              showZagSnackBar(
                title: episode['seriesTitle'],
                message: 'Sonarr integration coming soon',
                type: ZagSnackbarType.INFO,
              );
            },
            child: Row(
              children: [
                // Thumbnail
                Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    color: Colors.grey.shade800,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.network(
                      episode['thumbnail'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.tv_rounded,
                            size: 30,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          episode['seriesTitle'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          episode['episodeTitle'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${episode['seasonNumber']}x${episode['episodeNumber'].toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            Text(
                              episode['network'],
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF35C5F4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscoverNavigationBar extends StatelessWidget {
  final PageController? pageController;
  static List<ScrollController> scrollControllers = List.generate(
    icons.length,
    (_) => ScrollController(),
  );

  static const List<IconData> icons = [
    Icons.movie_rounded,
    Icons.tv_rounded,
    Icons.calendar_today_rounded,
    Icons.search_rounded,
  ];

  static const List<String> titles = [
    'Movies',
    'TV Shows',
    'Calendar',
    'Search',
  ];

  const _DiscoverNavigationBar({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBottomNavigationBar(
      pageController: pageController,
      scrollControllers: scrollControllers,
      icons: icons,
      titles: titles,
      onTabChange: (index) {
        // All tabs navigate normally within the PageView
      },
    );
  }
}