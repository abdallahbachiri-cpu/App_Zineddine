import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onRoleSelected;

  const RoleSelector({
    super.key,
    required this.controller,
    this.validator,
    this.onRoleSelected,
  });

  void _showRolePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choisir votre profil",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildRoleOption(
                context, 
                "Chef / Vendeur", 
                "seller", 
                Icons.store_rounded
              ),
              const SizedBox(height: 12),
              _buildRoleOption(
                context, 
                "Client / Acheteur", 
                "buyer", 
                Icons.shopping_bag_rounded
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleOption(
    BuildContext context, 
    String label, 
    String value, 
    IconData icon
  ) {
    final isSelected = controller?.text == value;
    
    return InkWell(
      onTap: () {
        controller?.text = value;
        if (onRoleSelected != null) {
          onRoleSelected!(value);
        }
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppConsts.accentColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppConsts.accentColor.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: isSelected ? AppConsts.accentColor : Colors.grey.shade600
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppConsts.accentColor : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppConsts.accentColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: true,
      onTap: () => _showRolePicker(context),
      decoration: InputDecoration(
        labelText: "Votre rôle",
        hintText: "Cliquez pour choisir",
        prefixIcon: const Icon(Icons.person_pin_rounded),
        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
