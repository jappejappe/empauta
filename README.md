# empauta

MVP mobile em Flutter para consumir as principais notícias do New York Times em
um feed vertical, uma matéria por tela.

As telas completas de Salvos e Perfil continuam fora deste MVP.

## Configuração

1. Crie uma chave em [NYT Developer](https://developer.nytimes.com/).
2. Crie uma cópia do arquivo `.env.example` e renomeie-a como `.env` na raiz do projeto.
3. Substitua o valor de exemplo pela sua chave:

```env
NYT_API_KEY=coloque_sua_chave_aqui
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
