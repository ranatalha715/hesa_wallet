import 'package:flutter/cupertino.dart';

class DeepLinkProvider with ChangeNotifier {
  String? pendingOperation;
  Uri? pendingUri;

  void setPendingOperation(String operation, Uri uri) {
    pendingOperation = operation;
    pendingUri = uri;
    notifyListeners();
  }

  void clearPendingOperation() {
    pendingOperation = null;
    pendingUri = null;
    notifyListeners();
  }
}
