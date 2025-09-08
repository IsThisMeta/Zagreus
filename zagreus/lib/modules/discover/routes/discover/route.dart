import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

class DiscoverHomeRoute extends StatefulWidget {
  const DiscoverHomeRoute({Key? key}) : super(key: key);

  @override
  State<DiscoverHomeRoute> createState() => _State();
}

class _State extends State<DiscoverHomeRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<RadarrMovie> _recentlyDownloaded = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadRecentlyDownloaded();
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
  
  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.DISCOVER,
      drawer: ZagDrawer(page: ZagModule.DISCOVER.key),
      appBar: ZagAppBar(
        title: 'Discover',
        useDrawer: true,
      ),
      body: _body(),
    );
  }
  
  Widget _body() {
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
              style: const TextStyle(color: Colors.grey),
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
      child: _recentlyDownloaded.isEmpty 
        ? _emptyState()
        : ListView(
            controller: scrollController,
            padding: EdgeInsets.only(top: 8),
            children: [
              _sectionHeader(),
              if (_recentlyDownloaded.isNotEmpty) _recentlyDownloadedSection(),
              const SizedBox(height: 32),
            ],
          ),
    );
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
  
  Widget _sectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF6688FF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Discover',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
            ],
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
                  child: movie.remotePoster != null
                    ? Image.network(
                        movie.remotePoster!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _posterPlaceholder(movie);
                        },
                      )
                    : _posterPlaceholder(movie),
                ),
              ),
              const SizedBox(height: 8),
              // Movie title
              Text(
                movie.title ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 14,
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
}