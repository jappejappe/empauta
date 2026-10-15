import 'package:flutter/material.dart';

import '../models/news_category.dart';

class CategoryEndPage extends StatelessWidget {
  const CategoryEndPage({
    super.key,
    required this.category,
    required this.suggestions,
    required this.onSelectCategory,
  }) : assert(suggestions.length == 4);

  final NewsCategory category;
  final List<NewsCategory> suggestions;
  final ValueChanged<NewsCategory> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('category-end-page'),
      color: const Color(0xFF140E0D),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.65, -0.55),
            radius: 1.15,
            colors: [Color(0xFF421812), Color(0xFF140E0D)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 88, 20, 104),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE34B36),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.done_all_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Você acabou a categoria ${category.label}.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Quer continuar? Escolha outra pauta para ler.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: suggestions.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.75,
                              ),
                          itemBuilder: (context, index) {
                            final suggestion = suggestions[index];
                            return _SuggestionCard(
                              category: suggestion,
                              onTap: () => onSelectCategory(suggestion),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.category, required this.onTap});

  final NewsCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFBF4F1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF0E4DE)),
      ),
      child: InkWell(
        key: ValueKey('end-suggestion-${category.slug}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.arrow_outward_rounded,
                color: Color(0xFFE34B36),
                size: 21,
              ),
              const Spacer(),
              Text(
                category.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1D211F),
                  fontSize: 14,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
