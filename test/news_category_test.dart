import 'package:empauta/models/news_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contains every supported NYT category exactly once', () {
    const expectedSlugs = [
      'arts',
      'automobiles',
      'books/review',
      'business',
      'fashion',
      'food',
      'health',
      'home',
      'insider',
      'magazine',
      'movies',
      'nyregion',
      'obituaries',
      'opinion',
      'politics',
      'realestate',
      'science',
      'sports',
      'sundayreview',
      'technology',
      'theater',
      't-magazine',
      'travel',
      'upshot',
      'us',
      'world',
    ];

    expect(NewsCategory.all.map((category) => category.slug), expectedSlugs);
    expect(
      NewsCategory.all.map((category) => category.slug).toSet(),
      hasLength(26),
    );
  });
}
