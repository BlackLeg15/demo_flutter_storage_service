import 'package:flutter/material.dart';
import 'package:storage_service/app/core/services/storage/hive_impl/hive_storage_service.dart';
import 'package:storage_service/app/core/services/storage/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _counter = ValueNotifier<int>(0);
  late final Future<StorageService> _storageServiceFuture;
  StorageService? _storageService;
  final storageValueRx = ValueNotifier<String>(DateTime.now().toString());

  @override
  void initState() {
    super.initState();
    _storageServiceFuture = HiveStorageService.getInstance(boxName: 'demo_app');
  }

  @override
  void dispose() {
    _storageService?.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    _counter.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            ValueListenableBuilder(
                valueListenable: _counter,
                builder: (context, counter, child) {
                  return Text(
                    '$counter',
                    style: Theme.of(context).textTheme.headline4,
                  );
                }),
            FutureBuilder(
                future: _storageServiceFuture,
                builder: (context, AsyncSnapshot<StorageService> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator.adaptive();
                  }
                  _storageService ??= snapshot.data!;
                  return Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _storageService?.write('key1', DateTime.now().toString());
                        },
                        icon: const Icon(Icons.web),
                        label: const Text('Clique para salvar uma nova data 😎'),
                        style: ElevatedButton.styleFrom(primary: Colors.green),
                      ),
                      ValueListenableBuilder(
                          valueListenable: storageValueRx,
                          builder: (context, value, child) {
                            return ElevatedButton.icon(
                              onPressed: () async {
                                final storageValue = await _storageService?.read<String>('key1');
                                storageValueRx.value = storageValue ?? '404 error';
                              },
                              icon: const Icon(Icons.web),
                              label: Text('Data lida 🤪: $value'),
                              style: ElevatedButton.styleFrom(primary: Colors.green),
                            );
                          }),
                    ],
                  );
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
