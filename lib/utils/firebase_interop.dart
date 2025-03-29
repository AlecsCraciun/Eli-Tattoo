@JS()
library firebase_interop;

import 'package:js/js.dart';
import 'package:js/js_util.dart';

// Interfață pentru funcțiile helper Firebase
@JS('FirebaseInterop')
class FirebaseInterop {
  external static dynamic handleThenable(dynamic promise);
  external static dynamic jsify(dynamic obj);
  external static dynamic dartify(dynamic obj);
}

// Mixin pentru clase Firebase
mixin FirebaseInteropMixin {
  Future<T> handleThenableMethod<T>(dynamic jsPromise) {
    try {
      return promiseToFuture<T>(FirebaseInterop.handleThenable(jsPromise));
    } catch (e) {
      print('Error in handleThenableMethod: $e');
      rethrow;
    }
  }

  dynamic jsifyData(dynamic data) {
    try {
      return FirebaseInterop.jsify(data);
    } catch (e) {
      print('Error in jsifyData: $e');
      rethrow;
    }
  }

  dynamic dartifyData(dynamic jsObject) {
    try {
      return FirebaseInterop.dartify(jsObject);
    } catch (e) {
      print('Error in dartifyData: $e');
      rethrow;
    }
  }
}

// Extensii pentru clase specifice Firebase
extension StorageReferenceInterop on dynamic {
  Future<T> handleStorageThenable<T>(dynamic jsPromise) {
    return promiseToFuture<T>(FirebaseInterop.handleThenable(jsPromise));
  }
}

extension MessagingInterop on dynamic {
  Future<T> handleMessagingThenable<T>(dynamic jsPromise) {
    return promiseToFuture<T>(FirebaseInterop.handleThenable(jsPromise));
  }
}

// Funcții utilitare pentru Firebase
class FirebaseUtils {
  static Future<T> handlePromise<T>(dynamic jsPromise) {
    return promiseToFuture<T>(FirebaseInterop.handleThenable(jsPromise));
  }

  static dynamic convertToJs(dynamic dartObject) {
    return FirebaseInterop.jsify(dartObject);
  }

  static dynamic convertToDart(dynamic jsObject) {
    return FirebaseInterop.dartify(jsObject);
  }
}
