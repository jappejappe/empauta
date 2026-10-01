import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_article.dart';
import '../models/news_category.dart';
import '../services/news_repository.dart';
import '../widgets/category_end_page.dart';
import '../widgets/news_story_page.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key, required this.repository});

  final NewsRepository repository;

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  late Future<List<NewsArticle>> _stories;
  final PageController _pageController = PageController();
  final Set<String> _savedStoryIds = {};
  NewsCategory _selectedCategory = NewsCategory.arts;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _stories = widget.repository.fetchTopStories(
      category: _selectedCategory.slug,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _currentPage = 0;
      _stories = widget.repository.fetchTopStories(
        category: _selectedCategory.slug,
      );
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _selectCategory(NewsCategory category) {
    if (category.slug == _selectedCategory.slug) return;

    setState(() {
      _selectedCategory = category;
      _currentPage = 0;
      _stories = widget.repository.fetchTopStories(category: category.slug);
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  Future<void> _showCategoryPicker() async {
    final category = await showModalBottomSheet<NewsCategory>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFFF7F4EE),
      showDragHandle: true,
      builder: (context) => _CategorySheet(selectedCategory: _selectedCategory),
    );

    if (!mounted || category == null) return;
    _selectCategory(category);
  }

  List<NewsCategory> _suggestionsFor(NewsCategory category) {
    final currentIndex = NewsCategory.all.indexWhere(
      (item) => item.slug == category.slug,
    );
    return List.generate(4, (offset) {
      final index = (currentIndex + offset + 1) % NewsCategory.all.length;
      return NewsCategory.all[index];
    }, growable: false);
  }

  void _toggleSaved(NewsArticle article) {
    setState(() {
      if (!_savedStoryIds.add(article.id)) {
        _savedStoryIds.remove(article.id);
      }
    });
  }

  Future<void> _copyLink(NewsArticle article) async {
    await Clipboard.setData(ClipboardData(text: article.url));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Link da matéria copiado.')));
  }

  Future<void> _openArticle(NewsArticle article) async {
    final uri = Uri.tryParse(article.url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir esta matéria.')),
      );
    }
  }

  void _showComingSoon(String destination) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$destination estará disponível em breve.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF161917),
      body: FutureBuilder<List<NewsArticle>>(
        future: _stories,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _LoadingView();
          }

          if (snapshot.hasError) {
            return _ErrorView(message: '${snapshot.error}', onRetry: _reload);
          }

          final stories = snapshot.data ?? const [];
          if (stories.isEmpty) {
            return _ErrorView(
              message:
                  'Nenhuma notícia de ${_selectedCategory.label.toLowerCase()} '
                  'foi encontrada agora.',
              onRetry: _reload,
            );
          }

          return Stack(
            children: [
              PageView.builder(
                key: const Key('news-feed'),
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: stories.length + 1,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  if (index == stories.length) {
                    return CategoryEndPage(
                      category: _selectedCategory,
                      suggestions: _suggestionsFor(_selectedCategory),
                      onSelectCategory: _selectCategory,
                    );
                  }

                  final article = stories[index];
                  return NewsStoryPage(
                    article: article,
                    isSaved: _savedStoryIds.contains(article.id),
                    onSave: () => _toggleSaved(article),
                    onShare: () => _copyLink(article),
                    onOpen: () => _openArticle(article),
                  );
                },
              ),
              _FeedHeader(
                category: _selectedCategory,
                currentPage: _currentPage + 1,
                totalPages: stories.length,
                isEnd: _currentPage >= stories.length,
                onCategoryTap: _showCategoryPicker,
                onRefresh: _reload,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 0) return;
          if (index == 1) {
            _showCategoryPicker();
            return;
          }
          const destinations = ['Início', 'Temas', 'Salvos', 'Perfil'];
          _showComingSoon(destinations[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Temas',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            label: 'Salvos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({
    required this.category,
    required this.currentPage,
    required this.totalPages,
    required this.isEnd,
    required this.onCategoryTap,
    required this.onRefresh,
  });

  final NewsCategory category;
  final int currentPage;
  final int totalPages;
  final bool isEnd;
  final VoidCallback onCategoryTap;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xCC000000), Colors.transparent],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 36),
            child: Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Text(
                          'empauta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.2,
                          ),
                        ),
                        const SizedBox(width: 14),
                        _CategoryPill(category: category, onTap: onCategoryTap),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isEnd ? 'Fim' : '$currentPage/$totalPages',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  tooltip: 'Atualizar notícias',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category, required this.onTap});

  final NewsCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEAF2EC),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: const Key('category-picker-button'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconForCategory(category.slug),
                size: 15,
                color: const Color(0xFF244C38),
              ),
              const SizedBox(width: 6),
              Text(
                category.label,
                style: const TextStyle(
                  color: Color(0xFF244C38),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: Color(0xFF244C38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  const _CategorySheet({required this.selectedCategory});

  final NewsCategory selectedCategory;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escolha sua pauta',
              style: TextStyle(
                color: Color(0xFF1D211F),
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Selecione um tema para atualizar o feed.',
              style: TextStyle(color: Color(0xFF66706A), fontSize: 14),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 600 ? 4 : 2;
                  return GridView.builder(
                    key: const Key('category-grid'),
                    itemCount: NewsCategory.all.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.35,
                    ),
                    itemBuilder: (context, index) {
                      final category = NewsCategory.all[index];
                      final isSelected = category.slug == selectedCategory.slug;
                      return Material(
                        color: isSelected
                            ? const Color(0xFF244C38)
                            : const Color(0xFFE9ECE8),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          key: ValueKey('category-${category.slug}'),
                          onTap: () => Navigator.pop(context, category),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Icon(
                                  _iconForCategory(category.slug),
                                  size: 19,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF244C38),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    category.label,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF1D211F),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 17,
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconForCategory(String slug) {
  return switch (slug) {
    'arts' => Icons.palette_outlined,
    'automobiles' => Icons.directions_car_outlined,
    'books/review' => Icons.menu_book_outlined,
    'business' => Icons.business_center_outlined,
    'fashion' => Icons.checkroom_outlined,
    'food' => Icons.restaurant_outlined,
    'health' => Icons.health_and_safety_outlined,
    'home' => Icons.home_outlined,
    'insider' => Icons.lock_open_outlined,
    'magazine' => Icons.auto_stories_outlined,
    'movies' => Icons.movie_outlined,
    'nyregion' => Icons.location_city_outlined,
    'obituaries' => Icons.history_edu_outlined,
    'opinion' => Icons.forum_outlined,
    'politics' => Icons.account_balance_outlined,
    'realestate' => Icons.apartment_outlined,
    'science' => Icons.science_outlined,
    'sports' => Icons.sports_soccer_outlined,
    'sundayreview' => Icons.newspaper_outlined,
    'technology' => Icons.devices_outlined,
    'theater' => Icons.theater_comedy_outlined,
    't-magazine' => Icons.style_outlined,
    'travel' => Icons.flight_outlined,
    'upshot' => Icons.insights_outlined,
    'us' => Icons.flag_outlined,
    'world' => Icons.public_outlined,
    _ => Icons.newspaper_outlined,
  };
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF161917),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFE34B36)),
            SizedBox(height: 18),
            Text(
              'Preparando suas notícias…',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.newspaper_rounded,
                size: 58,
                color: Color(0xFFE34B36),
              ),
              const SizedBox(height: 20),
              const Text(
                'empauta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
