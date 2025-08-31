import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// A card that displays information about the user's current location.
///
/// This widget shows the user's city and region, as well as the accuracy of the
/// location data. It also displays loading and error states.
class LocationInfoCard extends StatelessWidget {
  /// Whether the location is currently being fetched.
  final bool isLoading;

  /// An error message to display if the location could not be fetched.
  final String? errorMessage;

  /// The user's current city.
  final String currentCity;

  /// The user's current region.
  final String currentRegion;

  /// The user's current position.
  final Position? currentPosition;

  /// Creates a new [LocationInfoCard] widget.
  const LocationInfoCard({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.currentCity,
    required this.currentRegion,
    this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // An icon that indicates the current state of the location service.
                Icon(
                  isLoading
                      ? Icons.location_searching
                      : errorMessage != null
                          ? Icons.location_off
                          : Icons.location_on,
                  color: isLoading
                      ? theme.colorScheme.primary
                      : errorMessage != null
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The main text of the card, which displays the current state
                      // of the location service.
                      if (isLoading)
                        const Text(
                          "Getting your location...",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      else if (errorMessage != null)
                        Text(
                          errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        Text(
                          "$currentCity, $currentRegion",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      // The accuracy of the location data.
                      if (currentPosition != null && !isLoading)
                        Text(
                          "Accuracy: ${currentPosition!.accuracy.toStringAsFixed(0)}m",
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                // A loading indicator that is displayed when the location is being
                // fetched.
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}