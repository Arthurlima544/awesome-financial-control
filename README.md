Estamos criando um novo projeto e precisamos estabelecer algumas regras e padrões para garantir a qualidade do código, a organização do projeto e a eficiência no desenvolvimento. Aqui estão as regras que devemos seguir:

-Nunca adicionar variaveis diretamente no application.properties sempre usar uma ENV.

Backend deve seguir a estrutura de Repository, Service, Controller, Model, DTO, Mapper, Config.

Mobile deve seguir a estrutura de View, View-Model, Repository, Service conforme a documentacao oficial do flutter https://docs.flutter.dev/app-architecture/guide .

devemos estabelecer um padrão de commit, como o Conventional Commits https://www.conventionalcommits.org/en/v1.0.0/ para manter um histórico de commits claro e organizado. O formato do commit deve ser enchuto:

(US-1) @Arthurlima544 feat: add user authentication
(US-2) @Arthurlima544 fix: correct login bug
(US-3) @Arthurlima544 docs: update README with setup instructions
(US-4) @Arthurlima544 refactor: improve code structure in user service
(US-5) @Arthurlima544 test: add unit tests for authentication
(US-6) @Arthurlima544 chore: update dependencies

Deve se estabelecer um padrao de qualidade de código, como o uso de linters e formatação automática.

para isso precisamos de linters e formatadores de codigo.

Devemos configurar hook de pre push garantindo que o codigo esteja sem erros.

.git/hooks/pre-push
flutter build ios --no-codesign --debug

Todo codigo mergeado na main deve ser automaticamente deployado para o ambiente de homol, com github actions.

devemos ter um quality gate para garantir que o codigo mergeado na main esteja com qualidade, utilizando SonaerQube, ele
deve ser integrado com o github actions para bloquear merges que não atendam aos critérios de qualidade estabelecidos.

toda branch deve ser criada a partir da main, garantindo que o código esteja sempre atualizado com as últimas mudanças e evitando conflitos de merge.

codigos com problemas criticos de segurança identificados pela analise do sonnarqube devem ser corrigidos imediatamente, e nao deve de 
forma alguma ser enviados para o repositorio.

no mobile devemos ter cuidado ao separar o estado da interface, utilizando o padrão MVVM para garantir uma melhor organização do código e facilitar a manutenção, Nenhuma lógica de negócios deve ser implementada diretamente nas views, todas as operações devem ser delegadas para os view-models.

No backend devemos seguir o padrao de Testes BDD, utilizando cucumber e TestContainers.

No mobile devemos seguir o padrao de Testes BDD, utilizando o flutter test.

DEvemos estabelecer o Dia um do projeto, com deploy automático para o ambiente de homol e com as devidas configuracoes de qualidade
e seguranca.

O projeto é multi-plataforma, portanto ele deve funcionar no web e mobile pelo flutter.

Todos componentes do projeto devem serguir o mesmo padrao estabelecido, todos eles devem ser testados

Utilizar Swagger/OpenAPI no backend, Flyway para migrations, implementar um GlobalExceptionHandler.

proibir commits de .env.

todas strings do projeto devem ser armazenadas no i18n porém por enquanto somente com suporte para pt-br.

no mobile deve haver arquivos de configuracao gerais como AppSpacing, AppColors, AppTextStyles, etc.

Um das primeiras coisas que devemos fazer é separar ambiente de dev, prod e homol.

Deve haver um processo de Containerização

Backend deve utilizar JPA e padrão Builder() com records.

Devemos utilizar postegres 16 para armazenar dados do projeto.