import 'package:uuid/uuid.dart';

String generateUuid() {
  return const Uuid().v4();
}
