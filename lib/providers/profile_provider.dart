import 'package:flutter/material.dart';

/// Stores the user's profile details (no personal name is kept).
class ProfileProvider extends ChangeNotifier {
  String email = 'student@college.edu';
  String phone = '9876543210';
  String bio = '';
  String favouriteGenre = 'Lofi';

  void update({
    required String email,
    required String phone,
    required String bio,
    required String favouriteGenre,
  }) {
    this.email = email;
    this.phone = phone;
    this.bio = bio;
    this.favouriteGenre = favouriteGenre;
    notifyListeners();
  }
}
