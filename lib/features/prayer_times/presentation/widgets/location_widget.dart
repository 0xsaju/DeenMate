import 'package:flutter/material.dart';
import '../../domain/entities/location.dart';

/// Widget displaying current location information for prayer times
class LocationWidget extends StatelessWidget {

  const LocationWidget({
    required this.location, super.key,
  });
  final Location location;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.city,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _formatLocationDetails(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            location.timezone ?? 'UTC',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatLocationDetails() {
    final parts = <String>[];
    
    final region = location.region;
    if (region != null && region.isNotEmpty) {
      parts.add(region);
    }
    
    if (location.country.isNotEmpty && location.country != 'Unknown') {
      parts.add(location.country);
    }
    
    if (parts.isEmpty) {
      return '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}';
    }
    
    return parts.join(', ');
  }
}
