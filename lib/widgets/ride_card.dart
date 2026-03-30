import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/ride_model.dart';

class RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback? onTap;

  const RideCard({
    super.key,
    required this.ride,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
            ),
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

                  const SizedBox(height: 4),

                  Text(
                    "${ride.destination} • ${ride.date} • ${ride.time}",
                    style: AppTextStyles.caption,
                  ),

                  Text(
                    "Seats Available: ${ride.availableSeats}",
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            Text(
              "Rs. ${ride.price}",
              style: AppTextStyles.bodyMedium,
            ),


          ],
        ),
      ),
    );
  }
}