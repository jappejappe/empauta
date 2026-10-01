import 'package:empauta/models/news_article.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the NYT top stories response into typed objects', () {
    final response = TopStoriesResponse.fromJson({
      'status': 'OK',
      'copyright': 'Copyright',
      'section': 'arts',
      'last_updated': '2026-09-30T12:00:00-03:00',
      'num_results': 1,
      'results': [
        {
          'uri': 'nyt://article/example',
          'url': 'https://www.nytimes.com/example',
          'section': 'arts',
          'subsection': 'design',
          'title': 'Example story',
          'abstract': 'Example summary',
          'byline': 'By Example Author',
          'published_date': '2026-09-30T10:00:00-03:00',
          'updated_date': '2026-09-30T11:00:00-03:00',
          'multimedia': [
            {
              'url': 'https://example.com/small.jpg',
              'format': 'thumbLarge',
              'height': 150,
              'width': 150,
              'caption': '',
              'copyright': '',
            },
            {
              'url': 'https://example.com/large.jpg',
              'format': 'Super Jumbo',
              'height': 1365,
              'width': 2048,
              'caption': 'Example image',
              'copyright': 'Example photographer',
            },
          ],
        },
      ],
    });

    expect(response.status, 'OK');
    expect(response.section, 'arts');
    expect(response.results, hasLength(1));
    expect(response.results.single.title, 'Example story');
    expect(
      response.results.single.heroImageUrl,
      'https://example.com/large.jpg',
    );
    expect(response.results.single.publishedAt, isNotNull);
  });

  test('uses safe defaults when optional API values are absent', () {
    final article = NewsArticle.fromJson({'title': 'Only a title'});

    expect(article.title, 'Only a title');
    expect(article.images, isEmpty);
    expect(article.heroImageUrl, isNull);
    expect(article.summary, isEmpty);
  });
}
