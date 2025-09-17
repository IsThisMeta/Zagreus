import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

class TMDBPopularTVShowsRoute extends StatefulWidget {
  final List<Map<String, dynamic>>? initialData;

  const TMDBPopularTVShowsRoute({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<TMDBPopularTVShowsRoute> createState() => _State();
}

class _State extends State<TMDBPopularTVShowsRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _shows = [];
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
      _shows = widget.initialData!;
      _isLoading = false;
    } else {
      // Load data from API
      _loadPopularTVShows();
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
        _loadMoreShows();
      }
    }
  }

  Future<void> _loadPopularTVShows() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get user's region from locale
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';

      final shows = await TMDBApi.getPopularTVShows(page: 1, region: region);

      // Check against Sonarr library if available
      final sonarrState = context.read<SonarrState>();
      if (sonarrState.enabled && sonarrState.api != null) {
        try {
          sonarrState.fetchAllSeries();
          final sonarrSeriesMap = await sonarrState.series!;
          final sonarrSeries = sonarrSeriesMap.values.toList();

          for (final show in shows) {
            final tvdbId = show['tvdbId'] as int?;
            final title = show['title'] as String;

            // Check if this show is in Sonarr library
            final inLibrary = sonarrSeries.any((sonarrShow) {
              if (tvdbId != null && sonarrShow.tvdbId == tvdbId) {
                return true;
              }
              return sonarrShow.title?.toLowerCase() == title.toLowerCase();
            });
            show['inLibrary'] = inLibrary;

            if (inLibrary) {
              final sonarrShow = sonarrSeries.firstWhere(
                (s) =>
                    (tvdbId != null && s.tvdbId == tvdbId) ||
                    s.title?.toLowerCase() == title.toLowerCase(),
              );
              show['serviceItemId'] = sonarrShow.id;
            }
          }
        } catch (e) {
          // Silent fail - library check is optional
        }
      }

      setState(() {
        _shows = shows;
        _isLoading = false;
        _currentPage = 1;
        _hasMorePages = shows.isNotEmpty;
      });
    } catch (error, stack) {
      ZagLogger().error('Failed to load popular TV shows', error, stack);
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreShows() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';

      final nextPage = _currentPage + 1;
      final shows =
          await TMDBApi.getPopularTVShows(page: nextPage, region: region);

      // Check against Sonarr library if available
      final sonarrState = context.read<SonarrState>();
      if (sonarrState.enabled && sonarrState.api != null) {
        try {
          final sonarrSeriesMap = await sonarrState.series!;
          final sonarrSeries = sonarrSeriesMap.values.toList();

          for (final show in shows) {
            final tvdbId = show['tvdbId'] as int?;
            final title = show['title'] as String;

            final inLibrary = sonarrSeries.any((sonarrShow) {
              if (tvdbId != null && sonarrShow.tvdbId == tvdbId) {
                return true;
              }
              return sonarrShow.title?.toLowerCase() == title.toLowerCase();
            });
            show['inLibrary'] = inLibrary;

            if (inLibrary) {
              final sonarrShow = sonarrSeries.firstWhere(
                (s) =>
                    (tvdbId != null && s.tvdbId == tvdbId) ||
                    s.title?.toLowerCase() == title.toLowerCase(),
              );
              show['serviceItemId'] = sonarrShow.id;
            }
          }
        } catch (e) {
          // Silent fail - library check is optional
        }
      }

      setState(() {
        _shows.addAll(shows);
        _currentPage = nextPage;
        _hasMorePages = shows.isNotEmpty;
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
      title: 'Popular TV Shows',
      actions: [
        IconButton(
          icon: Icon(ZagIcons.REFRESH),
          onPressed: _loadPopularTVShows,
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Popular TV Shows',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPopularTVShows,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_shows.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Popular TV Shows Found',
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
      onRefresh: _loadPopularTVShows,
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _shows.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _shows.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return _showTile(_shows[index]);
        },
      ),
    );
  }

  Widget _showTile(Map<String, dynamic> show) {
    final bool inLibrary = show['inLibrary'] ?? false;
    final int? serviceItemId = show['serviceItemId'] as int?;
    final int? tmdbId = show['tmdbId'] as int?;

    return GestureDetector(
      onTap: () {
        if (inLibrary && serviceItemId != null) {
          SonarrRoutes.SERIES.go(
            params: {
              'series': serviceItemId.toString(),
            },
          );
        } else if (tmdbId != null) {
          SonarrRoutes.ADD_SERIES.go(
            queryParams: {
              'query': 'tmdb:$tmdbId',
            },
          );
        }
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
              _buildPosterImage(show),
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
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
              // Library indicator dot - bottom right
              if (inLibrary)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF35C5F4),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              // Rating badge - bottom left
              if (show['rating'] != null && show['rating'] > 0)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (show['rating'] ?? 0.0).toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Year in center bottom
              if (show['firstAirDate'] != null)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      show['firstAirDate'].toString().split('-').first,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterImage(Map<String, dynamic> show) {
    final posterUrl = show['poster'] as String?;

    if (posterUrl == null || posterUrl.isEmpty) {
      return _posterPlaceholder(show);
    }

    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _posterPlaceholder(show);
      },
    );
  }

  Widget _posterPlaceholder(Map<String, dynamic> show) {
    return Container(
      color: Colors.grey.shade800,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv,
              size: 40,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                show['title'] ?? 'Unknown',
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
}
