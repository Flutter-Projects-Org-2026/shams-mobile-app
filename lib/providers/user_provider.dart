import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  UserModel _currentUser = const UserModel(
    id: '',
    name: 'جاري التحميل...',
    email: '',
  );

  UserModel get currentUser => _currentUser;

  void updateProfile(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      _currentUser = UserModel.fromMap(data);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  void updateWorkshopStatus(bool hasWorkshop) {
    if (_currentUser.id.isNotEmpty) {
      _currentUser = _currentUser.copyWith(hasWorkshop: hasWorkshop);
      notifyListeners();
    }
  }

  void clearUserData() {
    _currentUser = const UserModel(
      id: '',
      name: 'مستخدم غير مسجل',
      email: '',
    );
    notifyListeners();
  }
}
