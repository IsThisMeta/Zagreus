import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

class SonarrRecentlyDownloadedRoute extends StatefulWidget {
  const SonarrRecentlyDownloadedRoute({Key? key}) : super(key: key);

  @override
  State<SonarrRecentlyDownloadedRoute> createState() => _State();
}

class _State extends State<SonarrRecentlyDownloadedRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<Map<String, dynamic>> _recentlyDownloadedShows = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadRecentlyDownloadedShows();
  }
  
  Future<void> _loadRecentlyDownloadedShows() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final sonarrState = context.read<SonarrState>();
      if (!sonarrState.enabled || sonarrState.api == null) {
        setState(() {
          _error = 'Sonarr is not enabled';
          _isLoading = false;
        });
        return;
      }
      
      final api = sonarrState.api!;
      
      // Fetch history sorted by date descending
      final history = await api.history.get(
        page: 1,
        pageSize: 100,
        sortKey: SonarrHistorySortKey.DATE,
        sortDirection: SonarrSortDirection.DESCENDING,
        includeEpisode: true,
        includeSeries: true,
      );
      
      // Filter to only downloadFolderImported events and dedupe by episodeId
      final downloadedRecords = <SonarrHistoryRecord>[];
      final seenEpisodeIds = <int>{};
      
      for (final record in history.records ?? []) {
        if (record.eventType == SonarrEventType.DOWNLOAD_FOLDER_IMPORTED &&
            record.episodeId != null &&
            !seenEpisodeIds.contains(record.episodeId)) {
          seenEpisodeIds.add(record.episodeId!);
          downloadedRecords.add(record);
          if (downloadedRecords.length >= 50) break; // Show more items on dedicated page
        }
      }
      
      // Map to UI format
      final shows = <Map<String, dynamic>>[];
      for (final record in downloadedRecords) {
        final episode = record.episode;
        final series = record.series;
        
        if (episode != null && series != null) {
          // Get fanart or poster image
          String? imageUrl;
          for (final image in series.images ?? []) {
            if (image.coverType == 'fanart') {
              imageUrl = image.remoteUrl ?? image.url;
              break;
            }
          }
          // Fallback to poster if no fanart
          if (imageUrl == null) {
            for (final image in series.images ?? []) {
              if (image.coverType == 'poster') {
                imageUrl = image.remoteUrl ?? image.url;
                break;
              }
            }
          }
          
          shows.add({
            'seriesTitle': series.title ?? 'Unknown Series',
            'episodeTitle': episode.title ?? 'Episode ${episode.episodeNumber}',
            'seasonNumber': episode.seasonNumber ?? 0,
            'episodeNumber': episode.episodeNumber ?? 0,
            'network': 'Downloaded',
            'thumbnail': imageUrl,
            'airDateUtc': episode.airDateUtc,
            'seriesId': series.id,
            'episodeId': episode.id,
            'date': record.date,
          });
        }
      }
      
      setState(() {
        _recentlyDownloadedShows = shows;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading Sonarr history: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
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
      title: 'Recently Downloaded',
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded),
          onPressed: _loadRecentlyDownloadedShows,
        ),
      ],
    ) as PreferredSizeWidget;
  }
  
  Widget _body() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ZagColours.accent),
        ),
      );
    }
    
    if (_error != null) {
      return ZagMessage.error(
        onTap: _loadRecentlyDownloadedShows,
      );
    }
    
    if (_recentlyDownloadedShows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_done_rounded,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Recently Downloaded Episodes',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Downloaded episodes will appear here',
              style: const TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadRecentlyDownloadedShows,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _recentlyDownloadedShows.length,
        itemBuilder: (context, index) {
          final episode = _recentlyDownloadedShows[index];
          return _episodeCard(episode);
        },
      ),
    );
  }
  
  Widget _episodeCard(Map<String, dynamic> episode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (episode['seriesId'] != null) {
                SonarrRoutes.SERIES.go(
                  params: {
                    'series': episode['seriesId'].toString(),
                  },
                );
              }
            },
            child: Row(
              children: [
                // Thumbnail
                Container(
                  width: 140,
                  height: 100,
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
                    child: episode['thumbnail'] != null
                        ? Image.network(
                            episode['thumbnail'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _thumbnailPlaceholder();
                            },
                          )
                        : _thumbnailPlaceholder(),
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
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${episode['seasonNumber']}x${episode['episodeNumber'].toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: ZagColours.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                episode['episodeTitle'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(episode['date']),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: ZagColours.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Downloaded',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: ZagColours.accent,
                                  fontWeight: FontWeight.w600,
                                ),
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
  
  Widget _thumbnailPlaceholder() {
    return Container(
      color: Colors.grey.shade700,
      child: Center(
        child: Icon(
          Icons.tv_rounded,
          size: 30,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}