import 'package:empauta/models/news_article.dart';
import 'package:empauta/screens/news_feed_screen.dart';
import 'package:empauta/services/news_repository.dart';
import 'package:empauta/services/translation_service.dart';
import 'package:empauta/widgets/flag_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTranslationService extends TranslationService {
  @override
  Future<NewsArticle> translateArticle(
    NewsArticle article, {
    String from = 'en',
    String to = 'pt',
  }) async {
    return article.copyWith(
      title: 'Título Traduzido: ${article.title}',
      summary: 'Resumo Traduzido: ${article.summary}',
      subsection: 'Subseção Traduzida',
    );
  }
}

class _MockNewsRepo implements NewsRepository {
  @override
  Future<List<NewsArticle>> fetchTopStories({String category = 'arts'}) async {
    return const [
      NewsArticle(
        uri: 'art://1',
        url: 'https://example.com/art1',
        section: 'arts',
        subsection: 'music',
        title: 'Original English Title',
        summary: 'Original English Abstract',
        byline: 'By Reporter',
        publishedAt: null,
        updatedAt: null,
        images: [],
      ),
    ];
  }
}

void main() {
  testWidgets('displays translation flag button and toggles translation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _MockNewsRepo();
    final translationService = _FakeTranslationService();

    await tester.pumpWidget(
      MaterialApp(
        home: NewsFeedScreen(
          repository: repo,
          translationService: translationService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial state: English text, button shows "Traduzir" and Brazilian flag
    expect(find.text('Original English Title'), findsOneWidget);
    expect(find.byKey(const Key('translation-flag-button')), findsOneWidget);
    expect(find.byType(BrazilFlagIcon), findsOneWidget);
    expect(find.text('Traduzir'), findsOneWidget);

    // Tap translation button to translate
    await tester.tap(find.byKey(const Key('translation-flag-button')));
    await tester.pumpAndSettle();

    // Verify translated state: Title is translated, badge "TRADUZIDO" is shown, button shows "PT"
    expect(
      find.text('Título Traduzido: Original English Title'),
      findsOneWidget,
    );
    expect(find.text('PT'), findsOneWidget);
    expect(find.text('TRADUZIDO'), findsOneWidget);
    expect(find.text('Notícias traduzidas para o português 🇧🇷'), findsOneWidget);

    // Tap again to switch back to original English
    await tester.tap(find.byKey(const Key('translation-flag-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Original English Title'), findsOneWidget);
    expect(find.text('Traduzir'), findsOneWidget);
    expect(
      find.text('Exibindo notícias no idioma original (inglês) 🇺🇸'),
      findsOneWidget,
    );
  });
}
