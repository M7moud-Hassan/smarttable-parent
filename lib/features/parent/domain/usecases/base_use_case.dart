import '../../data/datasources/db.dart';
import '../repositories/repo.dart';

/// كل حالة استخدام تحمل المستودع ومصدر البيانات، فلا تعرف الشاشة عنهما شيئاً
/// ولا يعرف المستودع عن الشاشة شيئاً.
abstract class BaseUseCase {
  const BaseUseCase({required this.repo, required this.db});

  final Repo repo;
  final Db db;
}
