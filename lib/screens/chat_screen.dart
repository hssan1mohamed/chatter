import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_test/core/controller/massages_cubit/massages_cubit.dart';
import 'package:firebase_test/core/maneger/colors.dart';
import 'package:firebase_test/models/massage_model.dart';
import 'package:firebase_test/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_Screen';

  const ChatScreen({
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  List<MassageModel> massageList = [];
  String? userId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserId();
    BlocProvider.of<MassagesCubit>(context).getMessages();
  }

  getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId =  prefs.getString('id');
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        title: const Text('Chatter',
            style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString('id', '');
                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(context, 'loginPage');
              },
              icon: const Icon(Icons.login_outlined))
        ],
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Expanded(child: BlocBuilder<MassagesCubit, MassagesState>(
              builder: (context, state) {
                if (state is MassagesDone) {
                  massageList = state.messages;
                }
                return massageList.isEmpty
                    ? const Center(
                        child: Text('No Massages'),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        reverse: true,
                        controller: _scrollController,
                        itemCount: massageList.length,
                        itemBuilder: (context, i) {
                          return massageList[i].id == userId.toString()
                              ? BubbleChat(
                                  text: massageList[i].msg,
                                  isMe: true,
                                  id: massageList[i].id,
                                )
                              : BubbleChat(
                                  text: massageList[i].msg,
                                  isMe: false,
                                  id: massageList[i].id,
                                );
                        });
              },
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DefaultFieldForm(
                  suffix: Icons.send,
                  controller: textEditingController,
                  suffixPress: () async {
                    if (formKey.currentState!.validate()) {
                      BlocProvider.of<MassagesCubit>(context).sendMessage(
                          message: textEditingController.text,
                          userId: userId.toString());
                      textEditingController.clear();
                      _scrollController.animateTo(
                        0,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500),
                      );
                    }
                  },
                  keyboard: TextInputType.name,
                  hint: 'write your massage',
                  valid: (value) {
                    if (value.isEmpty) {
                      return 'Please Enter any thing';
                    }

                    return null;
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class BubbleChat extends StatelessWidget {
  const BubbleChat({
    super.key,
    required this.text,
    required this.isMe,
    required this.id,
  });

  final String text;
  final String id;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isMe ? mainColor : KprimaryColor,
          borderRadius: isMe
              ? const BorderRadius.only(
                  bottomRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                )
              : const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
        ),
        child: Column(
          children: [
            Text(text),
            Text(
              id.replaceAll('@yahoo.com', ''),
              style: TextStyle(
                  color: isMe ? Colors.white : Colors.red, fontSize: 10),
            )
          ],
        ),
      ),
    );
  }
}
