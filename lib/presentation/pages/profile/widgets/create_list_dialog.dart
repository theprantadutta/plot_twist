import 'package:flutter/material.dart';

import '../../../../data/firestore/firestore_service.dart';
import '../../../core/app_colors.dart';

void showCreateListDialog(BuildContext context) {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Create a New List"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "List Name"),
              validator: (value) =>
                  value!.isEmpty ? "Please enter a name" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description (Optional)",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: AppColors.darkTextSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              FirestoreService().createCustomList(
                nameController.text.trim(),
                descController.text.trim(),
              );
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.auroraPink,
          ),
          child: const Text("Create", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
