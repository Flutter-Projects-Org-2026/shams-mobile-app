import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  // Dummy user data representing the logged-in user
  UserModel _currentUser = const UserModel(
    id: 'u1',
    name: 'مستخدم تجريبي',
    email: 'test@shams.com',
    profileImageUrl: 'assets/images/logo/shams logo.png',
    bio: 'مهتم بالطاقة المتجددة',
    isVerified: true,
  );

  UserModel get currentUser => _currentUser;

  void updateProfile(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }
}
