class NewsCategory {
  const NewsCategory({required this.slug, required this.label});

  final String slug;
  final String label;

  static const arts = NewsCategory(slug: 'arts', label: 'Artes');

  static const all = <NewsCategory>[
    arts,
    NewsCategory(slug: 'automobiles', label: 'Automóveis'),
    NewsCategory(slug: 'business', label: 'Negócios'),
    NewsCategory(slug: 'fashion', label: 'Moda'),
    NewsCategory(slug: 'food', label: 'Gastronomia'),
    NewsCategory(slug: 'health', label: 'Saúde'),
    NewsCategory(slug: 'home', label: 'Casa'),
    NewsCategory(slug: 'insider', label: 'Insider'),
    NewsCategory(slug: 'movies', label: 'Cinema'),
    NewsCategory(slug: 'nyregion', label: 'Nova York'),
    NewsCategory(slug: 'obituaries', label: 'Obituários'),
    NewsCategory(slug: 'opinion', label: 'Opinião'),
    NewsCategory(slug: 'politics', label: 'Política'),
    NewsCategory(slug: 'realestate', label: 'Imóveis'),
    NewsCategory(slug: 'science', label: 'Ciência'),
    NewsCategory(slug: 'sports', label: 'Esportes'),
    NewsCategory(slug: 'sundayreview', label: 'Sunday Review'),
    NewsCategory(slug: 'technology', label: 'Tecnologia'),
    NewsCategory(slug: 'theater', label: 'Teatro'),
    NewsCategory(slug: 't-magazine', label: 'T Magazine'),
    NewsCategory(slug: 'travel', label: 'Viagem'),
    NewsCategory(slug: 'upshot', label: 'The Upshot'),
    NewsCategory(slug: 'us', label: 'Estados Unidos'),
    NewsCategory(slug: 'world', label: 'Mundo'),
  ];

  static bool supports(String slug) {
    return all.any((category) => category.slug == slug);
  }
}
