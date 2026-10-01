import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/news_article.dart';

abstract interface class NewsRepository {
  Future<List<NewsArticle>> fetchTopStories({String category = 'arts'});
}

class NyTimesNewsRepository implements NewsRepository {
  NyTimesNewsRepository({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? '';

  static const supportedCategory = 'arts';
  static const _baseUrl = 'api.nytimes.com';

  final http.Client _client;
  final String _apiKey;

  @override
  Future<List<NewsArticle>> fetchTopStories({
    String category = supportedCategory,
  }) async {
    final normalizedKey = _apiKey.trim();
    if (normalizedKey.isEmpty || normalizedKey == 'coloque_sua_chave_aqui') {
      throw const NewsApiException(
        'Adicione sua chave do New York Times no arquivo .env.',
      );
    }

    if (category != supportedCategory) {
      throw const NewsApiException(
        'Neste MVP, apenas a categoria arts está disponível.',
      );
    }

    final uri = Uri.https(_baseUrl, '/svc/topstories/v2/$category.json', {
      'api-key': normalizedKey,
    });

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw NewsApiException(_messageForStatus(response.statusCode));
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const NewsApiException('A API retornou uma resposta inválida.');
      }

      return TopStoriesResponse.fromJson(decoded).results;
    } on TimeoutException {
      throw const NewsApiException(
        'A conexão demorou demais. Verifique sua internet e tente novamente.',
      );
    } on http.ClientException {
      throw const NewsApiException(
        'Não foi possível acessar as notícias. Verifique sua conexão.',
      );
    } on FormatException {
      throw const NewsApiException('Não foi possível interpretar as notícias.');
    }
  }

  String _messageForStatus(int statusCode) {
    return switch (statusCode) {
      401 || 403 => 'A chave da API é inválida ou não tem permissão.',
      429 =>
        'O limite de requisições foi atingido. Tente novamente em instantes.',
      >= 500 => 'O New York Times está indisponível no momento.',
      _ => 'Não foi possível carregar as notícias (erro $statusCode).',
    };
  }
}

class NewsApiException implements Exception {
  const NewsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
