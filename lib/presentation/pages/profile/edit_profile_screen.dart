import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../application/profile/profile_providers.dart';
import '../../../data/firestore/firestore_service.dart';
import '../../core/app_colors.dart';
import '../auth/widgets/auth_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  bool _isLoading = false;

  // State variables for image handling
  File? _pickedImageFile;
  String? _networkImageUrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userDocumentStreamProvider).asData?.value;
    _fullNameController = TextEditingController(
      text: user?.data()?['fullName'] ?? '',
    );
    _usernameController = TextEditingController(
      text: user?.data()?['username'] ?? '',
    );
    _networkImageUrl = user?.data()?['avatarUrl'];
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // Image Picking Logic
  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Compress image
    );
    if (pickedImage == null) return;
    setState(() => _pickedImageFile = File(pickedImage.path));
  }

  // Save Changes Logic
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? newAvatarUrl;
      if (_pickedImageFile != null) {
        newAvatarUrl = await FirestoreService().uploadAvatar(_pickedImageFile!);
      }

      await FirestoreService().updateUserProfile(
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim(),
        avatarUrl: newAvatarUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update profile: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar Section
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.darkSurface,
                    backgroundImage: _pickedImageFile != null
                        ? FileImage(_pickedImageFile!)
                        : (_networkImageUrl != null
                                  ? NetworkImage(_networkImageUrl!)
                                  : null)
                              as ImageProvider?,
                    child:
                        (_pickedImageFile == null && _networkImageUrl == null)
                        ? const FaIcon(
                            FontAwesomeIcons.userAstronaut,
                            size: 50,
                            color: AppColors.darkTextSecondary,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.auroraPink,
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Form Fields
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) =>
                    value!.isEmpty ? "Full name can't be empty" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
                validator: (value) =>
                    value!.isEmpty ? "Username can't be empty" : null,
              ),
              const SizedBox(height: 40),
              // Save Button
              AuthButton(
                text: "Save Changes",
                onPressed: _saveChanges,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
