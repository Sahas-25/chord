import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/library_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive.dart';
import '../widgets/section_title.dart';

/// Screen 6 - Basic profile with an editable form and validation.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late String _genre;

  static const List<String> _genres = [
    'Pop',
    'Lofi',
    'Electronic',
    'Acoustic',
    'Classical',
    'Hip Hop',
  ];

  @override
  void initState() {
    super.initState();
    // Fill the text fields with the saved profile details.
    final profile = context.read<ProfileProvider>();
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _bioController = TextEditingController(text: profile.bio);
    _genre = profile.favouriteGenre;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // ---------- validators: return null when valid, or an error message ----------
  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w.\-]+@[\w\-]+(\.[\w\-]+)+$').hasMatch(text)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(text)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? _validateBio(String? value) {
    if ((value?.length ?? 0) > 80) return 'Bio can have at most 80 characters';
    return null;
  }

  void _save() {
    // validate() runs every validator and shows the error messages.
    if (!_formKey.currentState!.validate()) return;

    context.read<ProfileProvider>().update(
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          bio: _bioController.text.trim(),
          favouriteGenre: _genre,
        );
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final library = context.watch<LibraryProvider>();

    return PageContainer(
      maxWidth: 700,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ----- avatar + name -----
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.purple,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              profile.email,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 16),

          // ----- small statistics -----
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Liked songs',
                  value: '${library.likedSongs.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Playlists',
                  value: '${library.savedPlaylists.length}',
                ),
              ),
            ],
          ),

          const SectionTitle('Edit details'),

          // ----- the form -----
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppTheme.inputDecoration(
                        label: 'Email', icon: Icons.email_outlined),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: AppTheme.inputDecoration(
                        label: 'Mobile number', icon: Icons.phone_outlined),
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 2,
                    decoration: AppTheme.inputDecoration(
                        label: 'Bio (optional)', icon: Icons.edit_outlined),
                    validator: _validateBio,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _genre,
                    dropdownColor: AppColors.cardLight,
                    decoration: AppTheme.inputDecoration(
                        label: 'Favourite genre',
                        icon: Icons.music_note_outlined),
                    items: [
                      for (final g in _genres)
                        DropdownMenuItem(value: g, child: Text(g)),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _genre = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.purple,
            ),
          ),
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
