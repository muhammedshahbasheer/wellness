import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wellness/firebase_options.dart';
import 'package:wellness/loginpage.dart';
import 'package:wellness/splashscreen.dart';
import 'package:wellness/trainer/registationtrainer.dart';
import 'package:wellness/loginpage.dart';
import 'package:wellness/user/registrationuser.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'Wellness',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/user': (context) => const RegistrationPage(),
        '/trainer': (context) => const TrainerRegistrationPage(),
        '/login':(context)=> const LoginPage(),
      },
    );
  }
}
