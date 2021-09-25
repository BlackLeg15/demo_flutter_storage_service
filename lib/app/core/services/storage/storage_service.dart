import 'dart:async';

abstract class StorageService {
  Future<T?> read<T>(String key);
  Future<bool> write<T>(String key, T value);
  Future<bool> deleteOne(String key);
  Future<bool> clear();
  FutureOr<void> dispose();
}
