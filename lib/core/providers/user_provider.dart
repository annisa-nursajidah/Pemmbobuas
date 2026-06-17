import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  String get displayName => _currentUser?.name ?? 'Pengguna';
  String get userId => _currentUser?.id ?? '';
  String get userPhone => _currentUser?.formattedPhone ?? '';
  String get avatarUrl => _currentUser?.avatarUrl ?? '';

  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
