import 'package:firebase_test/core/controller/auth_cubit/auth_cubit.dart';
import 'package:firebase_test/screens/chat_screen.dart';
import 'package:firebase_test/screens/sing_up_screen.dart';
import 'package:firebase_test/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/maneger/colors.dart';
import '../core/maneger/showSnackBar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
        body: BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          return showSnackBar(context, state.error);
        } else if (state is AuthDone) {
          Navigator.pushReplacementNamed(context, ChatScreen.id,
              arguments: emailContriller.text);
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 40),
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
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text('Login',
                        style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                  DefaultFieldForm(
                    labelStyle: const TextStyle(color: Colors.black),
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
                    labelStyle: const TextStyle(color: Colors.black),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          BlocProvider.of<AuthCubit>(context).loginUser(
                              email: emailContriller.text,
                              password: passwordContriller.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: KprimaryColor,
                      ),
                      child: state is AuthLoading
                          ? const Center(child: CircularProgressIndicator())
                          : const Text(
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
                            Navigator.of(context).pushNamed(SignUpScreen.id);
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
        );
      },
    ));
  }
}
