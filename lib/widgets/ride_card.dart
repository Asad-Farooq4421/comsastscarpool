import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/ride_model.dart';

Widget RideCard(Ride ride) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
        )
      ],
    ),
    child: Row(
      children: [
        const CircleAvatar(radius: 25),
        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ride.driverName, style: AppTextStyles.bodyLarge),
              Text(
                "${ride.destination} • ${ride.date} • ${ride.time}",
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),

        Text("Rs. ${ride.price}", style: AppTextStyles.bodyMedium),
      ],
    ),
  );
}