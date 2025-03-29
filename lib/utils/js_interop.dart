@JS()
library js_interop;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

@JS('Promise')
external dynamic get Promise;

@JS('Object')
external dynamic get Object;

@JS('window')
external dynamic get window;

@JS('Error')
class JsError {
  external String get message;
  external String get stack;
}

@JS()
@anonymous
class PromiseJsImpl<T> {
  external PromiseJsImpl(void Function(void Function(T) resolve, Function reject) executor);
  external PromiseJsImpl then(dynamic Function(T) onFulfilled, [Function onRejected]);
}

// Funcții de bază pentru interoperabilitate
@JS('handleThenable')
external dynamic handleThenable(dynamic promise);

@JS('jsify')
external dynamic jsify(dynamic obj);

@JS('dartify')
external dynamic dartify(dynamic obj);

@JS('JSON.parse')
external dynamic jsonParse(String text);

@JS('JSON.stringify')
external String stringify(dynamic obj);

// Funcții helper pentru conversia obiectelor
dynamic convertToJs(dynamic dartObject) {
  if (dartObject == null) return null;
  return js_util.jsify(dartObject);
}

dynamic convertToDart(dynamic jsObject) {
  if (jsObject == null) return null;
  return js_util.dartify(jsObject);
}

// Funcții helper pentru Promise
Future<T> promiseToFuture<T>(dynamic jsPromise) {
  return js_util.promiseToFuture<T>(jsPromise);
}

bool isPromise(dynamic object) {
  if (object == null) return false;
  return js_util.hasProperty(object, 'then') &&
         js_util.getProperty(object, 'then') is Function;
}

// Extensii pentru clasele Firebase
extension FirebaseInterop on dynamic {
  dynamic get jsObject => this;
  
  Future<T> handleThenableMethod<T>(dynamic Function() method) async {
    try {
      final result = method();
      if (isPromise(result)) {
        return await promiseToFuture<T>(result);
      }
      return result as T;
    } catch (e) {
      print('Error in handleThenableMethod: $e');
      rethrow;
    }
  }
}

// Funcții utilitare pentru Firebase Storage
Map<String, dynamic>? convertMetadata(dynamic jsMetadata) {
  if (jsMetadata == null) return null;
  return convertToDart(jsMetadata) as Map<String, dynamic>?;
}

dynamic convertCustomMetadata(Map<String, dynamic>? metadata) {
  if (metadata == null) return null;
  return convertToJs(metadata);
}

// Funcții pentru messaging
Map<String, dynamic>? convertMessageData(dynamic jsData) {
  if (jsData == null) return null;
  return convertToDart(jsData) as Map<String, dynamic>?;
}

// Funcție generică pentru handleThenable
Future<T> handleThenableFunction<T>(dynamic Function() operation) async {
  try {
    final result = operation();
    if (isPromise(result)) {
      return await promiseToFuture<T>(result);
    }
    return result as T;
  } catch (e) {
    print('Error in handleThenableFunction: $e');
    rethrow;
  }
}
