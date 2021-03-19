import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

enum IsolateProcess { JSON_DECODING }

class IsolateDataWrapper {
  final IsolateProcess isolateProcess;
  final dynamic message;
  final int identifier;

  IsolateDataWrapper(this.isolateProcess, this.message, this.identifier);
}

class CompleterWrapper<T> {
  Completer<T> completer;
  int identifier;

  CompleterWrapper() {
    completer = new Completer<T>();
    identifier = DateTime.now().millisecondsSinceEpoch;
  }
}

class Worker {
  Isolate anotherIsolate;
  SendPort anotherSendPort;
  StreamController mainListener = new StreamController.broadcast();
  Completer<void> isolateState = new Completer();
  Map<String, CompleterWrapper<dynamic>> pool = {};

  Worker() {
    _init();
  }

  Future<void> dispose() async {
    await mainListener.close();
    anotherIsolate.kill(priority: 0);
  }

  Future<void> init() async {
    return await isolateState.future;
  }

  static void anotherIsolateEntry(SendPort sendPort) {
    ReceivePort receiverPort = new ReceivePort();
    sendPort.send(receiverPort.sendPort);
    receiverPort.listen((dynamic data) async {
      if (data is IsolateDataWrapper) {
        data.message["sendPort"] = sendPort;
        data.message["identifier"] = data.identifier;
        if (data.isolateProcess == IsolateProcess.JSON_DECODING) {
          _jsonDecodingInIsolate(json)
        }
      }
    }, onError: (error) {
      print("Error");
    });
  }

  void _init() async {
    final mainReceivePort = new ReceivePort();
    if (mainListener.isClosed) mainListener = new StreamController.broadcast();
    anotherIsolate = await Isolate.spawn(
        anotherIsolateEntry, mainReceivePort.sendPort,
        onError: mainReceivePort.sendPort, onExit: mainReceivePort.sendPort);
    mainReceivePort.listen((onData) {
      mainListener.add(onData);
    }, onError: (error) {
      print("Error");
    });

    mainListener.stream.listen((data) async {
      if (data is SendPort) {
        anotherSendPort = data;
        isolateState.complete();
      } else if (data is IsolateDataWrapper) {
        print("Data type in main isolate is ${data.isolateProcess}");
        print("Data in main isolate is ${data.message}");
        complete(data);
      }
      else if (data == null) {
        await dispose();
        isolateState = new Completer();
        _init();
      }
    });
  }

  void complete(IsolateDataWrapper data) {
    final com = pool.remove(data.identifier.toString());
    if (com != null) {
      com.completer.complete(data.message);
      pool.remove(com);
    }
  }
}
