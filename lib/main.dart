import 'package:firebase_test/core/controller/auth_cubit/auth_cubit.dart';
import 'package:firebase_test/core/controller/massages_cubit/massages_cubit.dart';
import 'package:firebase_test/core/maneger/consts.dart';
import 'package:firebase_test/screens/chat_screen.dart';
import 'package:firebase_test/screens/sing_up_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString('id') == null) {
    id = '';
  } else {
    id = prefs.getString('id');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
        BlocProvider(
          create: (context) => MassagesCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          'loginPage': (context) => const LoginScreen(),
          SignUpScreen.id: (context) => SignUpScreen(),
          ChatScreen.id: (context) => const ChatScreen(),
        },
        initialRoute: id == null || id == '' ? 'loginPage' : ChatScreen.id,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
