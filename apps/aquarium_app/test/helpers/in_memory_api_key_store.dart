import 'package:danio/services/api_key_store.dart';

class InMemoryTestApiKeyStore implements ApiKeyStore {
  String? value;
  Object? readError;
  Object? writeError;
  Object? deleteError;

  @override
  Future<String?> read() async {
    final error = readError;
    if (error != null) throw error;
    return value;
  }

  @override
  Future<void> write(String value) async {
    final error = writeError;
    if (error != null) throw error;
    this.value = value;
  }

  @override
  Future<void> delete() async {
    final error = deleteError;
    if (error != null) throw error;
    value = null;
  }
}
