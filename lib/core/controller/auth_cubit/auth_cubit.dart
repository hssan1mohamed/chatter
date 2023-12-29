import 'package:bloc/bloc.dart';
// ignore: depend_on_referenced_packages
import "package:meta/meta.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> loginUser(
      {required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', email);
      emit(AuthDone());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(AuthError(error: 'No user found for that email.'));
      } else if (e.code == 'wrong-password') {
        emit(AuthError(error: 'Wrong password provided for that user.'));
      } else {
        emit(AuthError(error: e.message.toString()));
      }
    } catch (e) {
      emit(AuthError(error: e.toString()));
    }
  }

  Future<void> registerUser(
      {required String name,
      required String email,
      required String password}) async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', email);
      emit(AuthDone());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(AuthError(error: 'The password provided is too weak.'));
      } else if (e.code == 'email-already-in-use') {
        emit(AuthError(error: 'The account already exists for that email.'));
      } else {
        emit(AuthError(error: e.message.toString()));
      }
    } on Exception catch (e) {
      emit(AuthError(error: e.toString()));
    }
  }
}
