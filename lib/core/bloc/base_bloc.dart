import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../errors/failure.dart';

/// أساس كل بلوك في التطبيق: يحمل نتيجة آخر نداء ويختصر فكّها.
abstract class BaseBloc<E, S> extends Bloc<E, S> {
  BaseBloc(super.initialState);

  late Either<Failure, dynamic> result;

  static T get<T extends Bloc>(BuildContext context) => BlocProvider.of<T>(context);

  /// ينفّذ [value] على القيمة الناجحة فقط، ويتجاهل الفشل لأن رسالته تُعرض
  /// من اعتراض dio.
  void emitDone(Function(dynamic) value) {
    result.fold((l) => null, (r) => value(r));
  }

  /// كـ `emitDone` لكنها تتيح للشاشة إظهار حالة الفشل بنفسها.
  void emitResult({
    required Function(dynamic) onDone,
    required Function(Failure) onFail,
  }) {
    result.fold(onFail, onDone);
  }
}
