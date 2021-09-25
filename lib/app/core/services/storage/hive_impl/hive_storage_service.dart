import 'dart:async';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../storage_service.dart';

class HiveStorageService extends StorageService {
  final boxCompleter = Completer<Box>();
  final String boxName;
  static HiveStorageService? _instance;

  HiveStorageService._(this.boxName);

  static Future<HiveStorageService> getInstance({required String boxName}) async {
    if (_instance != null) return _instance!;
    _instance = HiveStorageService._(boxName);
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    final appDir = await getApplicationDocumentsDirectory();
    final path = appDir.path;
    Hive.init(path);
    await _setup();
  }

  Future<void> _setup() async => boxCompleter.complete(await Hive.openBox(boxName));

  @override
  FutureOr<void> dispose() async {
    if (boxCompleter.isCompleted) {
      (await boxCompleter.future).close();
    }
  }

  @override
  Future<bool> clear() async {
    final box = await boxCompleter.future;
    //box.clear retorna int porque ele retorna keystore.clear(), que retorna frameList.length
    await box.clear();
    return true;
  }

  @override
  Future<bool> deleteOne(String key) async {
    final box = await boxCompleter.future;
    await box.delete(key);
    return true;
  }

  @override
  Future<T?> read<T>(String key) async {
    final box = await boxCompleter.future;
    return await box.get(key);
  }

  @override
  Future<bool> write<T>(String key, T value) async {
    final box = await boxCompleter.future;
    await box.put(key, value);
    return true;
  }
}
