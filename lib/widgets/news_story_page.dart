import 'package:flutter/material.dart';

import '../models/news_article.dart';
import 'flag_icon.dart';

class NewsStoryPage extends StatelessWidget {
  const NewsStoryPage({
    super.key,
    required this.article,
    required this.isSaved,
    required this.onSave,
    required this.onShare,
    required this.onOpen,
    this.isTranslated = false,
  });

  final NewsArticle article;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onOpen;
  final bool isTranslated;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Notícia: ${article.title}',
      child: Stack(
        fit: StackFit.expand,
        children: [
          _StoryImage(imageUrl: article.heroImageUrl),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.34, 0.62, 1],
                colors: [
                  Color(0x59000000),
                  Color(0x12000000),
                  Color(0xB3000000),
                  Color(0xF20A0C0B),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 82,
            bottom: 112,
            child: _StoryDetails(
              article: article,
              onOpen: onOpen,
              isTranslated: isTranslated,
            ),
          ),
          Positioned(
            right: 12,
            bottom: 128,
            child: _StoryActions(
              isSaved: isSaved,
              onSave: onSave,
              onShare: onShare,
              onOpen: onOpen,
            ),
          ),
          const Positioned(right: 20, top: 112, child: _SwipeHint()),
        ],
      ),
    );
  }
}

class _StoryImage extends StatelessWidget {
  const _StoryImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return const _ImageFallback();

    return Image.network(
      url,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _ImageFallback(showLoader: true);
      },
      errorBuilder: (_, _, _) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({this.showLoader = false});

  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF221614),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3D1D19), Color(0xFF160E0D)],
          ),
        ),
        child: Center(
          child: showLoader
              ? const CircularProgressIndicator(color: Colors.white70)
              : const Icon(
                  Icons.palette_outlined,
                  size: 92,
                  color: Colors.white24,
                ),
        ),
      ),
    );
  }
}

class _StoryDetails extends StatelessWidget {
  const _StoryDetails({
    required this.article,
    required this.onOpen,
    this.isTranslated = false,
  });

  final NewsArticle article;
  final VoidCallback onOpen;
  final bool isTranslated;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Text(
                'T',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'The New York Times',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (article.subsection.isNotEmpty || isTranslated) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (article.subsection.isNotEmpty)
                Text(
                  article.subsection.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFF8C75),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              if (isTranslated)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x33009B3A),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0x66009B3A)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BrazilFlagIcon(width: 12, height: 8),
                      SizedBox(width: 4),
                      Text(
                        'TRADUZIDO',
                        style: TextStyle(
                          color: Color(0xFF66E68E),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Text(
          article.title,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            height: 1.02,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        if (article.summary.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            article.summary,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          _metadata,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onOpen,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE34B36),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            visualDensity: VisualDensity.compact,
          ),
          icon: const Icon(Icons.open_in_new_rounded, size: 17),
          label: const Text('Ler matéria'),
        ),
      ],
    );
  }

  String get _metadata {
    final parts = <String>[];
    if (article.byline.isNotEmpty) parts.add(article.byline);
    if (article.publishedAt case final date?) {
      parts.add(
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}',
      );
    }
    return parts.join(' • ');
  }
}

class _StoryActions extends StatelessWidget {
  const _StoryActions({
    required this.isSaved,
    required this.onSave,
    required this.onShare,
    required this.onOpen,
  });

  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundAction(
          tooltip: isSaved ? 'Remover dos salvos' : 'Salvar notícia',
          icon: isSaved
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          onTap: onSave,
        ),
        const SizedBox(height: 12),
        _RoundAction(
          tooltip: 'Copiar link',
          icon: Icons.ios_share_rounded,
          onTap: onShare,
        ),
        const SizedBox(height: 12),
        _RoundAction(
          tooltip: 'Abrir notícia',
          icon: Icons.arrow_outward_rounded,
          onTap: onOpen,
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x66000000),
      shape: const CircleBorder(side: BorderSide(color: Color(0x33FFFFFF))),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        color: Colors.white,
        icon: Icon(icon),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'deslize',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 4),
        Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white60, size: 18),
      ],
    );
  }
}
