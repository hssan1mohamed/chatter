import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_test/screens/chat_screen.dart';
import 'package:firebase_test/screens/sing_up_screen.dart';
import 'package:firebase_test/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/maneger/colors.dart';
import '../core/maneger/showSnackBar.dart';
import '../widgets/loading_page.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailContriller = TextEditingController();

  var passwordContriller = TextEditingController();

  var formKey = GlobalKey<FormState>();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? LoadingWidget()
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 40),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        Text('Chatter',
                            style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 30,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 40,
                        ),
                        const Image(
                          height: 200,
                          width: 200,
                          image: AssetImage('assets/images/chat.png'),
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text('Login',
                              style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ),
                        DefaultFieldForm(
                          labelStyle: TextStyle(color: Colors.black),
                          controller: emailContriller,
                          keyboard: TextInputType.emailAddress,
                          valid: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter your Email';
                            } else if (!value.toString().contains('.com') ||
                                !value.toString().contains('@')) {
                              return 'Please Sure format of email';
                            }
                            return null;
                          },
                          label: 'Email Address',
                          prefix: Icons.email,
                          hint: 'Email Address',
                          hintStyle: const TextStyle(color: Colors.grey),
                          show: false,
                        ),
                        const SizedBox(height: 15),
                        DefaultFieldForm(
                          labelStyle: TextStyle(color: Colors.black),
                          controller: passwordContriller,
                          keyboard: TextInputType.visiblePassword,
                          valid: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter Your Password';
                            } else if (value.toString().length < 8) {
                              return 'Please sure password at last 8  ';
                            }
                            return null;
                          },
                          label: 'Password',
                          prefix: Icons.password,
                          hint: 'Password',
                          hintStyle: const TextStyle(color: Colors.grey),
                          show: false,
                        ),
                        const SizedBox(height: 15),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                try {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await loginUser();
                                  Navigator.pushReplacementNamed(
                                      context, ChatScreen.id,
                                      arguments: emailContriller.text);
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'id', emailContriller.text);
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'user-not-found') {
                                    showSnackBar(context,
                                        'No user found for that email.');
                                  } else if (e.code == 'wrong-password') {
                                    showSnackBar(context,
                                        'Wrong password provided for that user.');
                                  } else {
                                    showSnackBar(context, e.message.toString());
                                  }
                                } catch (error) {
                                  showSnackBar(context, error.toString());
                                }
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: KprimaryColor,
                            ),
                            child: const Text(
                              "Sign In",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Do not have an account? "),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(SignUpScreen.id);
                                },
                                child: const Text(
                                  "Register",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ));
  }

  Future<void> loginUser() async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailContriller.text, password: passwordContriller.text);
  }
}
