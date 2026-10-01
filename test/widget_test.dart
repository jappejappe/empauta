import 'package:empauta/main.dart';
import 'package:empauta/models/news_article.dart';
import 'package:empauta/services/news_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows stories and navigates through the vertical feed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(EmpautaApp(repository: _FakeNewsRepository()));
    await tester.pumpAndSettle();

    expect(find.text('empauta'), findsOneWidget);
    expect(find.text('Artes'), findsOneWidget);
    expect(find.text('Uma história sobre arte'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);

    await tester.fling(
      find.byKey(const Key('news-feed')),
      const Offset(0, -600),
      1200,
    );
    await tester.pumpAndSettle();

    expect(find.text('A próxima exposição'), findsOneWidget);
    expect(find.text('2/2'), findsOneWidget);
  });
}

class _FakeNewsRepository implements NewsRepository {
  @override
  Future<List<NewsArticle>> fetchTopStories({String category = 'arts'}) async {
    return const [
      NewsArticle(
        uri: 'nyt://article/1',
        url: 'https://example.com/1',
        section: 'arts',
        subsection: 'design',
        title: 'Uma história sobre arte',
        summary: 'Um resumo curto para o primeiro item do feed.',
        byline: 'Por Equipe empauta',
        publishedAt: null,
        updatedAt: null,
        images: [],
      ),
      NewsArticle(
        uri: 'nyt://article/2',
        url: 'https://example.com/2',
        section: 'arts',
        subsection: 'museus',
        title: 'A próxima exposição',
        summary: 'Outro resumo para validar a navegação vertical.',
        byline: 'Por Equipe empauta',
        publishedAt: null,
        updatedAt: null,
        images: [],
      ),
    ];
  }
}
