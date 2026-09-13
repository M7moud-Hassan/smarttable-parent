/// شكل جسم الخطأ الذي يردّه الخادم.
class ErrorModel {
  ErrorModel({this.detail, this.msg});

  final String? detail;
  final String? msg;

  factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
        detail: json['detail']?.toString(),
        msg: json['msg']?.toString(),
      );

  String get message => detail ?? msg ?? 'حدث خطأ غير متوقّع';
}
