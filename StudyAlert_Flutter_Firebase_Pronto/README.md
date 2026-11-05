# StudyAlert — Flutter + Firebase Cloud Messaging

Aplicativo demonstrativo para a disciplina Programação para Dispositivos Móveis. Possui três atividades fictícias e três casos de notificações FCM: simples, com imagem e com navegação para detalhes.

## Como compilar, sem Flutter instalado no PC

1. Crie um projeto gratuito em https://console.firebase.google.com/ (Spark).
2. Cadastre um app Android com ID exato **com.example.studyalert**.
3. Baixe o arquivo **google-services.json** e salve-o na **raiz** deste projeto (junto do pubspec.yaml).
4. Envie todos os arquivos para o repositório GitHub, incluindo a pasta oculta `.github` e o `google-services.json`.
5. Abra GitHub > Actions > Gerar APK StudyAlert > Run workflow (ou aguarde o workflow no push à main).
6. Abra a execução concluída > Artifacts > StudyAlert-APK. Baixe, extraia o ZIP e instale app-release.apk no seu Samsung.
7. Abra o app, permita notificações, use o botão 'Copiar token' e envie um teste pelo Firebase Console > Messaging > Criar campanha de notificações > Enviar mensagem de teste.

**Importante:** APK Extractor não compila APKs; ele extrai APKs de apps já instalados. O GitHub Actions compila o aplicativo.

## Dados dos três testes no Firebase Console

Em *DevOps & Engagement > Messaging > Nova campanha > Notificação*, preencha título e texto e use *Enviar mensagem de teste* com o token exibido no aplicativo. Coloque o app em segundo plano antes de cada envio. Para o desafio 2, este pacote já contém `imagem-notificacao.jpg` (31 KB): no campo de imagem da notificação, envie a imagem pelo editor do Firebase, se a opção de upload aparecer; caso contrário, hospede esse JPG publicamente e use a URL HTTPS direta.

| Desafio | Título | Mensagem | Extra |
| --- | --- | --- | --- |
| 1 | Nova atividade disponível! | Confira sua atividade de Flutter no StudyAlert. | sem extras |
| 2 | Hora de revisar! | Sua prova de Algoritmos está chegando. | Use a imagem `imagem-notificacao.jpg` fornecida neste pacote. No Composer, carregue-a ou informe a URL HTTPS pública direta; expanda o aviso no Android. |
| 3 | Entrega amanhã! | Toque para abrir sua atividade de Flutter. | Dados personalizados: `activity_id` = `1` |

Para validar desafio 3 com o aplicativo encerrado, abra o app antes ao menos uma vez, use a notificação e evite 'Forçar parada' nas configurações do Android, pois ela bloqueia mensagens até o app ser aberto novamente. Faça testes com o app em segundo plano e com ele removido da lista de recentes, se o dispositivo permitir entrega.

Se o Console exigir URL da imagem, uma opção é colocar uma imagem JPG pública em seu próprio repositório GitHub e usar a URL **raw.githubusercontent.com** da imagem. Uma URL da página web de visualização não serve; precisa apontar diretamente para o arquivo JPG/PNG, acessível publicamente.

Observação: no Android, mensagens FCM com imagem normalmente mostram a imagem ao expandir o aviso (big picture), dependendo da versão e do aparelho. Se você não vir a imagem, verifique formato/URL/tamanho e faça outro teste.

## Como funciona a navegação

O app usa `FirebaseMessaging.onMessageOpenedApp` para o caso em segundo plano e `FirebaseMessaging.instance.getInitialMessage()` para inicialização a partir de notificação. A chave `activity_id` seleciona o detalhe da atividade 1, 2 ou 3.

## Escopo

Sem autenticação, banco, backend, publicação na Play Store ou cartão de crédito. Apenas Flutter, Dart, Firebase Core, Firebase Messaging e compilação pelo GitHub Actions.
