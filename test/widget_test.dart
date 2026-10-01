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

    final repository = _FakeNewsRepository();
    await tester.pumpWidget(EmpautaApp(repository: repository));
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

    await tester.fling(
      find.byKey(const Key('news-feed')),
      const Offset(0, -600),
      1200,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('category-end-page')), findsOneWidget);
    expect(find.text('Você acabou a categoria Artes.'), findsOneWidget);
    expect(find.text('Fim'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('end-suggestion-automobiles')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('end-suggestion-books/review')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('end-suggestion-business')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('end-suggestion-fashion')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('end-suggestion-automobiles')));
    await tester.pumpAndSettle();

    expect(repository.requestedCategories.last, 'automobiles');
    expect(find.text('Automóveis'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('category-picker-button')));
    await tester.pumpAndSettle();

    expect(find.text('Escolha sua pauta'), findsOneWidget);
    expect(find.byKey(const Key('category-grid')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('category-world')),
      300,
      scrollable: find.descendant(
        of: find.byKey(const Key('category-grid')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('category-world')));
    await tester.pumpAndSettle();

    expect(repository.requestedCategories.last, 'world');
    expect(find.text('Mundo'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
  });
}

class _FakeNewsRepository implements NewsRepository {
  final List<String> requestedCategories = [];

  @override
  Future<List<NewsArticle>> fetchTopStories({String category = 'arts'}) async {
    requestedCategories.add(category);
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
