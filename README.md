# empauta

MVP mobile em Flutter para consumir as principais notícias do New York Times em
um feed vertical, uma matéria por tela.

## O que já funciona

- consulta às 26 categorias disponíveis da Top Stories API;
- seletor de temas pelo cabeçalho e pela navegação inferior;
- modelos Dart tipados com `factory fromJson` para resposta, notícia e imagem;
- feed vertical no estilo Reels;
- tela de fim da categoria com quatro sugestões para continuar lendo;
- imagem, título, resumo, autoria e data de cada notícia;
- abrir a matéria original no navegador;
- copiar o link e salvar itens durante a sessão;
- estados de carregamento, erro, chave ausente e lista vazia;
- navegação visual baseada no wireframe do Figma.

Categorias disponíveis: Artes, Automóveis, Livros, Negócios, Moda, Gastronomia,
Saúde, Casa, Insider, Revista, Cinema, Nova York, Obituários, Opinião, Política,
Imóveis, Ciência, Esportes, Sunday Review, Tecnologia, Teatro, T Magazine,
Viagem, The Upshot, Estados Unidos e Mundo.

As telas completas de Salvos e Perfil continuam fora deste MVP.

## Configuração

1. Crie uma chave em [NYT Developer](https://developer.nytimes.com/).
2. Abra o arquivo `.env` na raiz do projeto.
3. Substitua o valor de exemplo pela sua chave:

```env
NYT_API_KEY=sua_chave_aqui
```

4. Instale as dependências e execute:

```bash
flutter pub get
flutter run
```

O endpoint muda conforme a categoria selecionada:

```text
https://api.nytimes.com/svc/topstories/v2/{categoria}.json?api-key=SUA_CHAVE
```

> O `.env` está no `.gitignore`. O arquivo `.env.example` pode ser versionado
> com segurança. Em aplicativos mobile, variáveis empacotadas no app não são um
> cofre de segredos; para produção, prefira um backend intermediário que proteja
> a chave da API.

## Estrutura principal

```text
lib/
├── models/news_category.dart
├── models/news_article.dart
├── screens/news_feed_screen.dart
├── services/news_repository.dart
├── widgets/news_story_page.dart
└── main.dart
```

## Qualidade

```bash
flutter analyze
flutter test
```
