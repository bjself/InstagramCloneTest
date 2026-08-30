import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class ChatsProvider extends ChangeNotifier {
  final FirestoreService _db;

  List<ChatModel> _chats = [];
  final Map<String, UserModel> _usersCache = {};
  StreamSubscription<List<ChatModel>>? _chatsSub;

  ChatsProvider(this._db);

  List<ChatModel> get chats => List.unmodifiable(_chats);

  void init(String currentUid) {
    _chatsSub?.cancel();
    _chatsSub = _db.chatsStream().listen((chats) async {
      for (final chat in chats) {
        final otherId =
            chat.users.firstWhere((id) => id != currentUid, orElse: () => '');
        if (otherId.isEmpty) continue;
        if (!_usersCache.containsKey(otherId)) {
          final user = await _db.fetchUser(otherId);
          if (user != null) _usersCache[otherId] = user;
        }
        chat.otherUser = _usersCache[otherId];
      }
      _chats = chats;
      notifyListeners();
    });
  }

  bool hasUnread(String currentUid) {
    return _chats.any((c) => _isUnread(c, currentUid));
  }

  bool _isUnread(ChatModel chat, String currentUid) {
    // React Native stores `{uid}: false` when there is an unread message.
    // We can't read that field cleanly from a typed model,
    // so we track it separately if needed. For now always return false
    // (full unread tracking can be added via a raw Firestore field read).
    return false;
  }

  @override
  void dispose() {
    _chatsSub?.cancel();
    super.dispose();
  }
}
