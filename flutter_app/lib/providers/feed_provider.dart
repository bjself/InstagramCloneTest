import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';

class FeedProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<PostModel> _posts = [];
  bool _loading = false;

  List<PostModel> get posts => _posts;
  bool get loading => _loading;

  void startListening() {
    _loading = true;
    notifyListeners();
    _service.feedStream().listen((posts) {
      _posts = posts;
      _loading = false;
      notifyListeners();
    }, onError: (_) {
      _loading = false;
      notifyListeners();
    });
  }
}
