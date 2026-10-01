import 'package:empauta/models/news_category.dart';
import 'package:empauta/services/news_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('builds a valid Top Stories URL for every category', () async {
    final requestedUris = <Uri>[];
    final client = MockClient((request) async {
      requestedUris.add(request.url);
      return http.Response('{"status":"OK","results":[]}', 200);
    });
    final repository = NyTimesNewsRepository(
      client: client,
      apiKey: 'test-key',
    );

    for (final category in NewsCategory.all) {
      await repository.fetchTopStories(category: category.slug);
    }

    expect(requestedUris, hasLength(NewsCategory.all.length));
    for (var index = 0; index < NewsCategory.all.length; index++) {
      final category = NewsCategory.all[index];
      final uri = requestedUris[index];
      expect(uri.host, 'api.nytimes.com');
      expect(uri.path, '/svc/topstories/v2/${category.slug}.json');
      expect(uri.queryParameters['api-key'], 'test-key');
    }
  });

  test('rejects categories outside the supported catalog', () async {
    final repository = NyTimesNewsRepository(
      client: MockClient((_) async => http.Response('{}', 200)),
      apiKey: 'test-key',
    );

    expect(
      () => repository.fetchTopStories(category: 'not-a-category'),
      throwsA(
        isA<NewsApiException>().having(
          (error) => error.message,
          'message',
          contains('not-a-category'),
        ),
      ),
    );
  });
}
