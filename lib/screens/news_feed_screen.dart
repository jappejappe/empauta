import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_article.dart';
import '../services/news_repository.dart';
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
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _stories = widget.repository.fetchTopStories();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _currentPage = 0;
      _stories = widget.repository.fetchTopStories();
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
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
              message: 'Nenhuma notícia de artes foi encontrada agora.',
              onRetry: _reload,
            );
          }

          return Stack(
            children: [
              PageView.builder(
                key: const Key('news-feed'),
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: stories.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
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
                currentPage: _currentPage + 1,
                totalPages: stories.length,
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
    required this.currentPage,
    required this.totalPages,
    required this.onRefresh,
  });

  final int currentPage;
  final int totalPages;
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
                const Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          'empauta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.2,
                          ),
                        ),
                        SizedBox(width: 14),
                        _CategoryPill(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$currentPage/$totalPages',
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
  const _CategoryPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2EC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.palette_outlined, size: 15, color: Color(0xFF244C38)),
          SizedBox(width: 6),
          Text(
            'Artes',
            style: TextStyle(
              color: Color(0xFF244C38),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
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
