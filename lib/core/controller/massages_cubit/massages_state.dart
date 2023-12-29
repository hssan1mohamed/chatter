part of 'massages_cubit.dart';

@immutable
abstract class MassagesState {}

class MassagesInitial extends MassagesState {}
class MassagesDone extends MassagesState {
  final List<MassageModel> messages;

  MassagesDone({required this.messages});
}
