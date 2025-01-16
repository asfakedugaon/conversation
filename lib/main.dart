import 'package:conversation/signInPage/login_page.dart';
import 'package:conversation/signInPage/splash_screen.dart';
import 'package:conversation/viewmodel/chat_viewmodel.dart';
import 'package:conversation/viewmodel/user_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => UserViewModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => ChatViewModel(),
    )
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen());
    }
}
