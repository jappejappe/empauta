import 'dart:async';
import 'package:translator/translator.dart';

import '../models/news_article.dart';

/// A service that translates text and articles between languages (default EN -> PT)
/// using Google Translate with memory caching and graceful fallback.
class TranslationService {
  TranslationService({GoogleTranslator? translator})
    : _translator = translator ?? GoogleTranslator();

  final GoogleTranslator _translator;
  final Map<String, String> _cache = {};

  /// Translates [text] from [from] to [to].
  /// Returns the translated text, or the original [text] if an error occurs.
  Future<String> translate(
    String text, {
    String from = 'en',
    String to = 'pt',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;

    final cacheKey = '$from->$to:$trimmed';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final translation = await _translator
          .translate(trimmed, from: from, to: to)
          .timeout(const Duration(seconds: 8));
      final result = translation.text;
      _cache[cacheKey] = result;
      return result;
    } catch (_) {
      // In case of network errors or timeouts, fallback gracefully to original text.
      return text;
    }
  }

  /// Translates a [NewsArticle]'s title, summary, and subsection.
  Future<NewsArticle> translateArticle(
    NewsArticle article, {
    String from = 'en',
    String to = 'pt',
  }) async {
    try {
      final futures = <Future<String>>[
        translate(article.title, from: from, to: to),
        if (article.summary.isNotEmpty)
          translate(article.summary, from: from, to: to)
        else
          Future.value(''),
        if (article.subsection.isNotEmpty)
          translate(article.subsection, from: from, to: to)
        else
          Future.value(''),
      ];

      final results = await Future.wait(futures);
      return article.copyWith(
        title: results[0],
        summary: results[1],
        subsection: results[2],
      );
    } catch (_) {
      return article;
    }
  }

  /// Translates a list of [NewsArticle]s.
  Future<List<NewsArticle>> translateArticles(
    List<NewsArticle> articles, {
    String from = 'en',
    String to = 'pt',
  }) async {
    return Future.wait(
      articles.map((article) => translateArticle(article, from: from, to: to)),
    );
  }

  /// Clears the translation cache.
  void clearCache() => _cache.clear();

  /// Checks if a translation is already cached.
  bool isCached(String text, {String from = 'en', String to = 'pt'}) {
    return _cache.containsKey('$from->$to:${text.trim()}');
  }
}
