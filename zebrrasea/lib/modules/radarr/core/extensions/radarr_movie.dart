import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/extensions/int/duration.dart';
import 'package:zebrrasea/modules/radarr.dart';

extension ZebrraRadarrMovieExtension on RadarrMovie {
  String get zebrraRuntime {
    return this.runtime.asVideoDuration();
  }

  String get zebrraAlternateTitles {
    if (this.alternateTitles?.isNotEmpty ?? false) {
      return this.alternateTitles!.map((title) => title.title).join('\n');
    }
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraGenres {
    if (this.genres?.isNotEmpty ?? false) return this.genres!.join('\n');
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraStudio {
    if (this.studio?.isNotEmpty ?? false) return this.studio!;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraYear {
    if (this.year != null && this.year != 0) return this.year.toString();
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraMinimumAvailability {
    if (this.minimumAvailability != null) {
      return this.minimumAvailability!.readable;
    }
    return ZebrraUI.TEXT_EMDASH;
  }

  String zebrraDateAdded([bool short = false]) {
    if (this.added != null) return this.added!.asDateOnly(shortenMonth: short);
    return ZebrraUI.TEXT_EMDASH;
  }

  bool get zebrraIsInCinemas {
    if (this.inCinemas != null)
      return this.inCinemas!.toLocal().isBefore(DateTime.now());
    return false;
  }

  String zebrraInCinemasOn([bool short = false]) {
    if (this.inCinemas != null)
      return this.inCinemas!.asDateOnly(shortenMonth: short);
    return ZebrraUI.TEXT_EMDASH;
  }

  String zebrraPhysicalReleaseDate([bool short = false]) {
    if (this.physicalRelease != null)
      return this.physicalRelease!.asDateOnly(shortenMonth: short);
    return ZebrraUI.TEXT_EMDASH;
  }

  String zebrraDigitalReleaseDate([bool short = false]) {
    if (this.digitalRelease != null)
      return this.digitalRelease!.asDateOnly(shortenMonth: short);
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraReleaseDate {
    if (this.zebrraEarlierReleaseDate != null)
      return this.zebrraEarlierReleaseDate!.asDateOnly();
    return ZebrraUI.TEXT_EMDASH;
  }

  String zebrraTags(List<RadarrTag> tags) {
    if (tags.isNotEmpty) return tags.map<String?>((t) => t.label).join('\n');
    return ZebrraUI.TEXT_EMDASH;
  }

  bool get zebrraIsReleased {
    if (this.status == RadarrAvailability.RELEASED) return true;
    if (this.digitalRelease != null)
      return this.digitalRelease!.toLocal().isBefore(DateTime.now());
    if (this.physicalRelease != null)
      return this.physicalRelease!.toLocal().isBefore(DateTime.now());
    return false;
  }

  String get zebrraFileSize {
    if (!this.hasFile!) return ZebrraUI.TEXT_EMDASH;
    return this.sizeOnDisk.asBytes();
  }

  Text zebrraHasFileTextObject() {
    if (this.hasFile!)
      return Text(
        zebrraFileSize,
        style: const TextStyle(
          color: ZebrraColours.accent,
          fontSize: ZebrraUI.FONT_SIZE_H3,
          fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
        ),
      );
    return const Text(
      '',
      style: TextStyle(
        fontSize: ZebrraUI.FONT_SIZE_H3,
        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
      ),
    );
  }

  Text zebrraNextReleaseTextObject() {
    DateTime now = DateTime.now();
    // If we already have a file or it is released
    if (this.hasFile! || zebrraIsReleased)
      return const Text(
        '',
        style: TextStyle(fontSize: ZebrraUI.FONT_SIZE_H3),
      );
    // In Cinemas
    if (this.inCinemas != null && this.inCinemas!.toLocal().isAfter(now)) {
      String _date = this.inCinemas!.asDaysDifference().toUpperCase();
      return Text(
        _date == 'TODAY' ? _date : 'IN $_date',
        style: const TextStyle(
          color: ZebrraColours.orange,
          fontSize: ZebrraUI.FONT_SIZE_H3,
          fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
        ),
      );
    }
    DateTime? _release = zebrraEarlierReleaseDate;
    // Releases
    if (_release != null) {
      String _date = _release.asDaysDifference().toUpperCase();
      return Text(
        _date == 'TODAY' ? _date : 'IN $_date',
        style: const TextStyle(
          color: ZebrraColours.blue,
          fontSize: ZebrraUI.FONT_SIZE_H3,
          fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
        ),
      );
    }
    // Unknown case
    return const Text(
      '',
      style: TextStyle(
        fontSize: ZebrraUI.FONT_SIZE_H3,
        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
      ),
    );
  }

  /// Compare two movies by their release dates. Returns an integer value compatible with `.sort()` in arrays.
  ///
  /// Compares and uses the earlier date between `physicalRelease` and `digitalRelease`.
  int zebrraCompareToByReleaseDate(RadarrMovie movie) {
    if (this.physicalRelease == null &&
        this.digitalRelease == null &&
        movie.physicalRelease == null &&
        movie.digitalRelease == null)
      return this
          .sortTitle!
          .toLowerCase()
          .compareTo(movie.sortTitle!.toLowerCase());
    if (this.physicalRelease == null && this.digitalRelease == null) return 1;
    if (movie.physicalRelease == null && movie.digitalRelease == null)
      return -1;
    DateTime a = (this.physicalRelease ?? DateTime(9999))
            .isBefore((this.digitalRelease ?? DateTime(9999)))
        ? this.physicalRelease!
        : this.digitalRelease!;
    DateTime b = (movie.physicalRelease ?? DateTime(9999))
            .isBefore((movie.digitalRelease ?? DateTime(9999)))
        ? movie.physicalRelease!
        : movie.digitalRelease!;
    int comparison = a.compareTo(b);
    if (comparison == 0)
      comparison = this
          .sortTitle!
          .toLowerCase()
          .compareTo(movie.sortTitle!.toLowerCase());
    return comparison;
  }

  /// Compare two movies by their cinema release date. Returns an integer value compatible with `.sort()` in arrays.
  int zebrraCompareToByInCinemas(RadarrMovie movie) {
    if (this.inCinemas == null && movie.inCinemas == null)
      return this
          .sortTitle!
          .toLowerCase()
          .compareTo(movie.sortTitle!.toLowerCase());
    if (this.inCinemas == null) return 1;
    if (movie.inCinemas == null) return -1;
    int comparison = this.inCinemas!.compareTo(movie.inCinemas!);
    if (comparison == 0)
      comparison = this
          .sortTitle!
          .toLowerCase()
          .compareTo(movie.sortTitle!.toLowerCase());
    return comparison;
  }

  /// Compares the digital and physical release dates and returns the earlier date.
  ///
  /// If both are null, returns null.
  DateTime? get zebrraEarlierReleaseDate {
    if (this.physicalRelease == null && this.digitalRelease == null)
      return null;
    if (this.physicalRelease == null) return this.digitalRelease;
    if (this.digitalRelease == null) return this.physicalRelease;
    return this.digitalRelease!.isBefore(this.physicalRelease!)
        ? this.digitalRelease
        : this.physicalRelease;
  }

  /// Creates a clone of the [RadarrMovie] object (deep copy).
  RadarrMovie clone() => RadarrMovie.fromJson(this.toJson());

  /// Copies changes from a [RadarrMoviesEditState] state object into a new [RadarrMovie] object.
  RadarrMovie updateEdits(RadarrMoviesEditState edits) {
    RadarrMovie movie = this.clone();
    movie.monitored = edits.monitored;
    movie.minimumAvailability = edits.availability;
    movie.qualityProfileId = edits.qualityProfile.id ?? this.qualityProfileId;
    movie.path = edits.path;
    movie.tags = edits.tags.map((t) => t.id).toList();
    return movie;
  }
}
