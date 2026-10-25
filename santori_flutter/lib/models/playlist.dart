import 'track.dart';

class Playlist {
  final int id;
  final String name;
  final String description;
  final int trackCount;
  final List<Track> tracks;

  const Playlist({
    required this.id,
    required this.name,
    this.description = '',
    this.trackCount = 0,
    this.tracks = const [],
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    var rawTracks = json['tracks'] as List<dynamic>? ?? [];
    List<Track> parsedTracks = rawTracks
        .map((t) => Track.fromJson(t as Map<String, dynamic>))
        .toList();

    return Playlist(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Untitled Playlist',
      description: json['description'] ?? '',
      trackCount: json['track_count'] ?? parsedTracks.length,
      tracks: parsedTracks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'track_count': trackCount,
      'tracks': tracks.map((t) => t.toJson()).toList(),
    };
  }
}
