class MassageModel {
  final String msg;
  final String id;
  const MassageModel({required this.msg, required this.id});

  factory MassageModel.fromJson(json) {
    return MassageModel(
        id : json['id'],
        msg: json['msg']);
  }
}
