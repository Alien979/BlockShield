import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'firebase_options.dart';
import 'providers/threat_provider.dart';
import 'providers/user_provider.dart';
import 'providers/reputation_provider.dart';
import 'services/ethereum_service.dart';
import 'services/ai_service.dart';
import 'services/notification_service.dart';
import 'services/blockchain_service.dart';
import 'pages/threat_list_page.dart';
import 'pages/data_submission_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/user_profile_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/blockchain_verification_page.dart';
import 'pages/threat_detail_page.dart';
import 'pages/home_page.dart';
import 'pages/verified_threats_page.dart';
import 'pages/blockchain_view_page.dart';
import 'models/threat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();
}

Future<void> initializeApp() async {
  // Set up logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  final log = Logger('BlockShield');

  try {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    final ethereumService = EthereumService();
    await ethereumService.initialize();

    final aiService = AIService();
    final notificationService = NotificationService();
    await notificationService.initialize();

    final blockchainService = BlockchainService();

    log.info('Services initialized successfully');

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => ThreatProvider(aiService, ethereumService)
                ..setBlockchainService(blockchainService)),
          ChangeNotifierProvider(create: (_) => UserProvider(ethereumService)),
          ChangeNotifierProvider(
              create: (_) => ReputationProvider(ethereumService)),
          Provider<EthereumService>.value(value: ethereumService),
          Provider<AIService>.value(value: aiService),
          Provider<NotificationService>.value(value: notificationService),
          Provider<BlockchainService>.value(value: blockchainService),
        ],
        child: const BlockShieldApp(),
      ),
    );
    log.info('App started successfully');
  } catch (e) {
    log.severe('Failed to initialize app', e);
    runApp(ErrorApp(error: e.toString()));
  }
}

class BlockShieldApp extends StatelessWidget {
  const BlockShieldApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlockShield',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        hintColor: Colors.blueAccent,
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        cardColor: Color(0xFFFFFFFF),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Color(0xFFFAFAFA),
          hintStyle: TextStyle(color: Colors.grey),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          color: Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Consumer<UserProvider>(
              builder: (_, userProvider, __) =>
                  userProvider.user == null ? SignInPage() : HomePage(),
            ),
        '/signup': (_) => SignUpPage(),
        '/home': (_) => HomePage(),
        '/dashboard': (_) => const DashboardPage(),
        '/threats': (_) => const ThreatListPage(),
        '/submit': (_) => const DataSubmissionPage(),
        '/profile': (_) => UserProfilePage(),
        '/verify': (_) => BlockchainVerificationPage(),
        '/verified_threats': (_) => VerifiedThreatsPage(),
        '/blockchain_view': (_) => BlockchainViewPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/threat_detail') {
          final threat = settings.arguments as Threat;
          return MaterialPageRoute(
              builder: (_) => ThreatDetailPage(threat: threat));
        }
        return null;
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('An error occurred: $error')),
      ),
    );
  }
}
