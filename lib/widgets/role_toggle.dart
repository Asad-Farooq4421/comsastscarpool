import 'package:flutter/material.dart';
import '../models/user_model.dart';


class RoleToggle extends StatelessWidget {
  final UserRole selectedRole;
  final Function(UserRole) onChanged;

  const RoleToggle({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton("Passenger", UserRole.passenger),
          _buildButton("Driver", UserRole.driver),
        ],
      ),
    );
  }

  Widget _buildButton(String text, UserRole role) {
    final bool isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () => onChanged(role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}