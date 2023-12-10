import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_test/core/maneger/colors.dart';
import 'package:firebase_test/core/maneger/showSnackBar.dart';
import 'package:firebase_test/models/massage_model.dart';
import 'package:firebase_test/widgets/loading_page.dart';
import 'package:firebase_test/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  ScrollController _scrollController = new ScrollController();
  String? userId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserId();
  }

  getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString('id');
  }

  @override
  Widget build(BuildContext context) {
  //  var email = ModalRoute.of(context)!.settings.arguments;
    TextEditingController textEditingController = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey();
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('massages')
            .orderBy('atTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          List<MassageModel> massageList = [];
          if (snapshot.hasData) {
            for (int i = 0; snapshot.data!.docs.length > i; i++) {
              massageList.add(MassageModel.fromJson(snapshot.data!.docs[i]));
            }
          }
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
                      Navigator.pushReplacementNamed(context, 'loginPage');
                    },
                    icon: Icon(Icons.login_outlined))
              ],
            ),
            body: snapshot.connectionState == ConnectionState.waiting
                ? LoadingWidget()
                : Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Expanded(
                            child: massageList.isEmpty
                                ? Center(
                                    child: Text('No Massages'),
                                  )
                                : ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    reverse: true,
                                    controller: _scrollController,
                                    itemCount: massageList.length,
                                    itemBuilder: (context, i) {
                                      return massageList[i].id ==
                                          userId.toString()
                                          ? bubbleChat(
                                              text: massageList[i].msg,
                                              isMe: true,
                                              id: massageList[i].id,
                                            )
                                          : bubbleChat(
                                              text: massageList[i].msg,
                                              isMe: false,
                                              id: massageList[i].id,
                                            );
                                    })),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DefaultFieldForm(
                              suffix: Icons.send,
                              controller: textEditingController,
                              suffixPress: () async {
                                if (formKey.currentState!.validate()) {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('massages')
                                        .add({
                                      'msg': textEditingController.text,
                                      'atTime': DateTime.now(),
                                      'id': userId.toString(),
                                    });
                                    textEditingController.clear();
                                    _scrollController.animateTo(
                                      0,
                                      curve: Curves.easeOut,
                                      duration:
                                          const Duration(milliseconds: 500),
                                    );
                                  } on FirebaseException catch (e) {
                                    print(e.message);
                                    showSnackBar(context, e.message);
                                  }
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
        });
  }
}

class bubbleChat extends StatelessWidget {
  const bubbleChat({
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
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isMe ? mainColor : KprimaryColor,
          borderRadius: isMe
              ? BorderRadius.only(
                  bottomRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                )
              : BorderRadius.only(
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
