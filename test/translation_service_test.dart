import 'package:empauta/models/news_article.dart';
import 'package:empauta/services/translation_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockTranslationService extends TranslationService {
  final Map<String, String> predefinedTranslations;

  _MockTranslationService(this.predefinedTranslations);

  @override
  Future<String> translate(
    String text, {
    String from = 'en',
    String to = 'pt',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;
    return predefinedTranslations[trimmed] ?? 'Traduzido: $trimmed';
  }
}

void main() {
  group('TranslationService', () {
    test('translates article title, summary and subsection', () async {
      final service = _MockTranslationService({
        'Breaking News': 'Notícia Urgente',
        'Summary of the event': 'Resumo do evento',
        'politics': 'política',
      });

      const article = NewsArticle(
        uri: 'test://1',
        url: 'https://example.com/1',
        section: 'world',
        subsection: 'politics',
        title: 'Breaking News',
        summary: 'Summary of the event',
        byline: 'By Author',
        publishedAt: null,
        updatedAt: null,
        images: [],
      );

      final translated = await service.translateArticle(article);

      expect(translated.title, 'Notícia Urgente');
      expect(translated.summary, 'Resumo do evento');
      expect(translated.subsection, 'política');
      expect(translated.url, article.url);
      expect(translated.uri, article.uri);
    });

    test('translateArticles translates a list of articles', () async {
      final service = _MockTranslationService({
        'Title 1': 'Título 1',
        'Title 2': 'Título 2',
      });

      const list = [
        NewsArticle(
          uri: '1',
          url: 'u1',
          section: 's',
          subsection: '',
          title: 'Title 1',
          summary: '',
          byline: '',
          publishedAt: null,
          updatedAt: null,
          images: [],
        ),
        NewsArticle(
          uri: '2',
          url: 'u2',
          section: 's',
          subsection: '',
          title: 'Title 2',
          summary: '',
          byline: '',
          publishedAt: null,
          updatedAt: null,
          images: [],
        ),
      ];

      final results = await service.translateArticles(list);

      expect(results, hasLength(2));
      expect(results[0].title, 'Título 1');
      expect(results[1].title, 'Título 2');
    });

    test('returns empty text unchanged', () async {
      final service = TranslationService();
      final result = await service.translate('   ');
      expect(result, '   ');
    });
  });
}
