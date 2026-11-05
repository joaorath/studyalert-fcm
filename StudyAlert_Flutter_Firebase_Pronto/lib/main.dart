import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const Color fundo = Color(0xFF0B1020);
const Color painel = Color(0xFF151D33);
const Color roxo = Color(0xFFA78BFA);

class Atividade {
  final String id;
  final String titulo;
  final String disciplina;
  final String prazo;
  final String descricao;
  final IconData icone;
  final Color cor;

  const Atividade({
    required this.id,
    required this.titulo,
    required this.disciplina,
    required this.prazo,
    required this.descricao,
    required this.icone,
    required this.cor,
  });
}

const List<Atividade> atividades = [
  Atividade(
    id: '1',
    titulo: 'Atividade de Flutter',
    disciplina: 'Programação Mobile',
    prazo: 'Entrega: amanhã',
    descricao:
        'Prepare um aplicativo Flutter que receba notificações do Firebase Cloud Messaging. '
        'Demonstre um alerta simples, outro com imagem e a abertura de uma tela ao tocar na mensagem.',
    icone: Icons.phone_android_rounded,
    cor: Color(0xFF8B5CF6),
  ),
  Atividade(
    id: '2',
    titulo: 'Revisão de Banco de Dados',
    disciplina: 'Banco de Dados',
    prazo: 'Revisar esta semana',
    descricao:
        'Revisar comandos SELECT, JOIN, GROUP BY e os principais conceitos de modelagem relacional.',
    icone: Icons.storage_rounded,
    cor: Color(0xFF38BDF8),
  ),
  Atividade(
    id: '3',
    titulo: 'Prova de Algoritmos',
    disciplina: 'Algoritmos',
    prazo: 'Prova em breve',
    descricao:
        'Estudar estruturas de dados, recursão, ordenação e complexidade de algoritmos. '
        'Separar exercícios para praticar.',
    icone: Icons.auto_stories_rounded,
    cor: Color(0xFFF59E0B),
  ),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const StudyAlertApp());
}

class StudyAlertApp extends StatefulWidget {
  const StudyAlertApp({super.key});

  @override
  State<StudyAlertApp> createState() => _StudyAlertAppState();
}

class _StudyAlertAppState extends State<StudyAlertApp> {
  StreamSubscription<RemoteMessage>? _aberturas;
  StreamSubscription<RemoteMessage>? _mensagensAbertas;
  String? _token;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _iniciarNotificacoes();
  }

  Future<void> _iniciarNotificacoes() async {
    // App em segundo plano: tocar na notificação abre a atividade indicada.
    _aberturas = FirebaseMessaging.onMessageOpenedApp.listen(_navegarPelaMensagem);

    // App encerrado: recupera a notificação que iniciou o aplicativo.
    final inicial = await FirebaseMessaging.instance.getInitialMessage();
    if (inicial != null) {
      _navegarPelaMensagem(inicial);
    }

    // Em primeiro plano, o Android não mostra o banner de FCM automaticamente.
    // Exibimos uma barra dentro do app apenas para facilitar os testes.
    _mensagensAbertas = FirebaseMessaging.onMessage.listen((mensagem) {
      final contexto = navigatorKey.currentContext;
      if (contexto == null) return;
      ScaffoldMessenger.of(contexto).showSnackBar(
        SnackBar(
          content: Text(
            '${mensagem.notification?.title ?? 'Novo aviso'}: '
            '${mensagem.notification?.body ?? 'Abra os detalhes no aplicativo.'}',
          ),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'ABRIR',
            onPressed: () => _navegarPelaMensagem(mensagem),
          ),
        ),
      );
    });

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final token = await FirebaseMessaging.instance.getToken();
      if (!mounted) return;
      setState(() => _token = token);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.toString());
    }
  }

  void _navegarPelaMensagem(RemoteMessage mensagem) {
    // Firebase Console > Dados personalizados:
    // chave = activity_id | valor = 1, 2 ou 3.
    final id = mensagem.data['activity_id'];
    if (id == null) return;
    Atividade? selecionada;
    for (final atividade in atividades) {
      if (atividade.id == id) {
        selecionada = atividade;
        break;
      }
    }
    if (selecionada == null) return;
    final destino = selecionada;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      navigatorKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (_) => DetalhesAtividade(atividade: destino),
        ),
      );
    });
  }

  @override
  void dispose() {
    _aberturas?.cancel();
    _mensagensAbertas?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyAlert',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: fundo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: roxo,
          brightness: Brightness.dark,
        ),
      ),
      home: HomePage(token: _token, erro: _erro),
    );
  }
}

class HomePage extends StatelessWidget {
  final String? token;
  final String? erro;

  const HomePage({super.key, required this.token, required this.erro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: fundo,
        title: const Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: roxo),
            SizedBox(width: 10),
            Text('StudyAlert', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4C1D95), Color(0xFF1E3A8A)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.school_rounded, size: 38, color: Colors.white),
                  SizedBox(height: 15),
                  Text(
                    'Seus estudos em dia!',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 7),
                  Text('Acompanhe atividades, provas e prazos em um só lugar.'),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Próximas atividades',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...atividades.map(
              (atividade) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  color: painel,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor: atividade.cor.withValues(alpha: 0.18),
                      child: Icon(atividade.icone, color: atividade.cor),
                    ),
                    title: Text(
                      atividade.titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('${atividade.disciplina}\n${atividade.prazo}'),
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DetalhesAtividade(atividade: atividade),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Notificações Firebase',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Copie o token para enviar notificações de teste pelo Firebase Console.',
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: painel,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (token != null) ...[
                    const Text('Token FCM', style: TextStyle(color: roxo)),
                    const SizedBox(height: 8),
                    SelectableText(
                      token!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: token!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Token copiado!')),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Copiar token'),
                    ),
                  ] else if (erro != null) ...[
                    const Text('Erro na conexão com Firebase'),
                    const SizedBox(height: 6),
                    SelectableText(erro!, style: const TextStyle(fontSize: 12)),
                  ] else
                    const Text('Aguardando autorização e token do Firebase...'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetalhesAtividade extends StatelessWidget {
  final Atividade atividade;

  const DetalhesAtividade({super.key, required this.atividade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da atividade'),
        backgroundColor: fundo,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: atividade.cor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(atividade.icone, size: 70, color: atividade.cor),
            ),
            const SizedBox(height: 24),
            Text(
              atividade.titulo,
              style: const TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(atividade.disciplina, style: const TextStyle(color: roxo)),
            const SizedBox(height: 22),
            Card(
              color: painel,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: roxo),
                    const SizedBox(width: 12),
                    Expanded(child: Text(atividade.prazo)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sobre esta atividade',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
            const SizedBox(height: 10),
            Text(
              atividade.descricao,
              style: const TextStyle(fontSize: 16, height: 1.55),
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Voltar para atividades'),
            ),
          ],
        ),
      ),
    );
  }
}
