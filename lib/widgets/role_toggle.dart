import 'package:flutter/material.dart';

enum UserRole {
  passenger,
  driver,
}

class RoleToggle extends StatelessWidget {
  final UserRole selectedRole;
  final Function(UserRole) onChanged;
  final bool? isDriverEnabled; // 👈 nullable

  const RoleToggle({
    super.key,
    required this.selectedRole,
    required this.onChanged,
    this.isDriverEnabled,
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

    final bool driverEnabled = isDriverEnabled ?? true; // 👈 fallback

    final bool isDisabled =
        role == UserRole.driver && !driverEnabled;

    return GestureDetector(
      onTap: isDisabled ? null : () => onChanged(role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDisabled
                ? Colors.grey // 👈 disabled text
                : isSelected
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}