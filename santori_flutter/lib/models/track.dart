class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String image;
  final String? streamUrl;
  final String? mediaPreviewUrl;
  final bool hasLyrics;
  final String year;
  final int hue;
  final bool isDemo;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album = '',
    this.duration = 180,
    this.image = '',
    this.streamUrl,
    this.mediaPreviewUrl,
    this.hasLyrics = false,
    this.year = '',
    this.hue = 210,
    this.isDemo = false,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown Track',
      artist: json['artist'] ?? 'Unknown Artist',
      album: json['album'] ?? '',
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration']?.toString() ?? '180') ?? 180,
      image: json['image'] ?? '',
      streamUrl: json['stream_url'],
      mediaPreviewUrl: json['media_preview_url'],
      hasLyrics: json['has_lyrics'] == true,
      year: json['year']?.toString() ?? '',
      hue: json['hue'] is int ? json['hue'] : 210,
      isDemo: json['is_demo'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'image': image,
      'stream_url': streamUrl,
      'media_preview_url': mediaPreviewUrl,
      'has_lyrics': hasLyrics,
      'year': year,
      'hue': hue,
      'is_demo': isDemo,
    };
  }
}
