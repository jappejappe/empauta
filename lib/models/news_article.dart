class NewsImage {
  const NewsImage({
    required this.url,
    required this.format,
    required this.height,
    required this.width,
    required this.caption,
    required this.copyright,
  });

  final String url;
  final String format;
  final int height;
  final int width;
  final String caption;
  final String copyright;

  factory NewsImage.fromJson(Map<String, dynamic> json) {
    return NewsImage(
      url: json['url'] as String? ?? '',
      format: json['format'] as String? ?? '',
      height: (json['height'] as num?)?.toInt() ?? 0,
      width: (json['width'] as num?)?.toInt() ?? 0,
      caption: json['caption'] as String? ?? '',
      copyright: json['copyright'] as String? ?? '',
    );
  }
}

class NewsArticle {
  const NewsArticle({
    required this.uri,
    required this.url,
    required this.section,
    required this.subsection,
    required this.title,
    required this.summary,
    required this.byline,
    required this.publishedAt,
    required this.updatedAt,
    required this.images,
  });

  final String uri;
  final String url;
  final String section;
  final String subsection;
  final String title;
  final String summary;
  final String byline;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final List<NewsImage> images;

  String? get heroImageUrl {
    NewsImage? largest;
    for (final image in images) {
      if (image.url.isEmpty) continue;
      if (largest == null || image.width > largest.width) {
        largest = image;
      }
    }
    return largest?.url;
  }

  String get id => uri.isNotEmpty ? uri : url;

  NewsArticle copyWith({
    String? uri,
    String? url,
    String? section,
    String? subsection,
    String? title,
    String? summary,
    String? byline,
    DateTime? publishedAt,
    DateTime? updatedAt,
    List<NewsImage>? images,
  }) {
    return NewsArticle(
      uri: uri ?? this.uri,
      url: url ?? this.url,
      section: section ?? this.section,
      subsection: subsection ?? this.subsection,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      byline: byline ?? this.byline,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
    );
  }

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final multimedia = json['multimedia'];

    return NewsArticle(
      uri: json['uri'] as String? ?? '',
      url: json['url'] as String? ?? '',
      section: json['section'] as String? ?? '',
      subsection: json['subsection'] as String? ?? '',
      title: json['title'] as String? ?? 'Sem título',
      summary: json['abstract'] as String? ?? '',
      byline: json['byline'] as String? ?? '',
      publishedAt: DateTime.tryParse(json['published_date'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_date'] as String? ?? ''),
      images: multimedia is List
          ? multimedia
                .whereType<Map<String, dynamic>>()
                .map(NewsImage.fromJson)
                .toList(growable: false)
          : const [],
    );
  }
}

class TopStoriesResponse {
  const TopStoriesResponse({
    required this.status,
    required this.copyright,
    required this.section,
    required this.lastUpdated,
    required this.numberOfResults,
    required this.results,
  });

  final String status;
  final String copyright;
  final String section;
  final DateTime? lastUpdated;
  final int numberOfResults;
  final List<NewsArticle> results;

  factory TopStoriesResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];

    return TopStoriesResponse(
      status: json['status'] as String? ?? '',
      copyright: json['copyright'] as String? ?? '',
      section: json['section'] as String? ?? '',
      lastUpdated: DateTime.tryParse(json['last_updated'] as String? ?? ''),
      numberOfResults: (json['num_results'] as num?)?.toInt() ?? 0,
      results: rawResults is List
          ? rawResults
                .whereType<Map<String, dynamic>>()
                .map(NewsArticle.fromJson)
                .toList(growable: false)
          : const [],
    );
  }
}
