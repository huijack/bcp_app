import 'package:bcp_app/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BCP App',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey[200],
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromRGBO(255, 154, 157, 50),
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
          )),
      home: const AuthPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}