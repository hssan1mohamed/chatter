import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_test/models/massage_model.dart';
import 'package:meta/meta.dart';

part 'massages_state.dart';

class MassagesCubit extends Cubit<MassagesState> {
  MassagesCubit() : super(MassagesInitial());

  void sendMessage({required String message ,required String userId})async{
    try {


      await FirebaseFirestore.instance
          .collection('massages')
          .add({
        'msg': message,
        'atTime': DateTime.now(),
        'id': userId,
      });
      getMessages();
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }
  void getMessages()async{
    List<MassageModel> massages=[];
    FirebaseFirestore.instance
        .collection('massages')
        .orderBy('atTime', descending: true)
        .snapshots().listen((event) {
          for(var doc in event.docs){
            massages.add(MassageModel.fromJson(doc));
          }

          emit(MassagesDone(messages: massages));
    });
  }
}
