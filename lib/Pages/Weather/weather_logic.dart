// weather_widget.dart
// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:testing2/services/DataSource/weather_api.dart';

class WeatherWidget extends StatefulWidget {
  final VoidCallback? onLocationError;
  final Function(WeatherLocationData)? onDataLoaded;
  final Widget Function(WeatherLocationData)? customBuilder;
  final bool autoLoad;

  const WeatherWidget({
    Key? key,
    this.onLocationError,
    this.onDataLoaded,
    this.customBuilder,
    this.autoLoad = true,
  }) : super(key: key);

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final WeatherApiService _weatherService = WeatherApiService();

  WeatherLocationData? _weatherData;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      loadWeatherData();
    }
  }

  Future<void> loadWeatherData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Request permission first
      final hasPermission = await _weatherService.requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }

      // Check if location services are enabled
      final isServiceEnabled = await _weatherService.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      // Get complete weather data
      final weatherData = await _weatherService.getCompleteWeatherData();

      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
      });

      // Notify parent widget
      if (widget.onDataLoaded != null) {
        widget.onDataLoaded!(weatherData);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      if (widget.onLocationError != null) {
        widget.onLocationError!();
      }

      debugPrint("Error loading weather data: $e");
    }
  }

  Future<void> refreshWeatherData() async {
    if (_isRefreshing || _isLoading) return;

    setState(() {
      _isRefreshing = true;
      _error = null;
    });

    try {
      final weatherData = await _weatherService.getCompleteWeatherData();

      setState(() {
        _weatherData = weatherData;
        _isRefreshing = false;
      });

      // Notify parent widget
      if (widget.onDataLoaded != null) {
        widget.onDataLoaded!(weatherData);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isRefreshing = false;
      });

      debugPrint("Error refreshing weather data: $e");
    }
  }

  void _showLocationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Disabled'),
        content: const Text(
          'Please enable location services to get weather information.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use custom builder if provided
    if (widget.customBuilder != null && _weatherData != null) {
      return widget.customBuilder!(_weatherData!);
    }
    // Default UI
    return RefreshIndicator(
      onRefresh: refreshWeatherData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading weather data...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadWeatherData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_weatherData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No weather data available'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadWeatherData,
              child: const Text('Load Weather'),
            ),
          ],
        ),
      );
    }

    return _buildWeatherCard(_weatherData!);
  }

  Widget _buildWeatherCard(WeatherLocationData data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.formattedLocation,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (_isRefreshing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Temperature and weather
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.currentTemperature.round()}°C',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      data.weatherDescription,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Season: ${data.season}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${data.hemisphere} Hemisphere',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Coordinates (optional, for debugging)
            if (false) // Set to true if you want to show coordinates
              // ignore: dead_code
              Text(
                'Lat: ${data.latitude.toStringAsFixed(4)}, '
                'Lon: ${data.longitude.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

// Standalone weather data provider (without UI)
class WeatherDataProvider {
  static final WeatherApiService _service = WeatherApiService();
  static WeatherLocationData? _cachedData;
  static DateTime? _lastFetch;
  static const Duration _cacheValidDuration = Duration(minutes: 10);

  /// Get weather data with caching
  static Future<WeatherLocationData> getWeatherData({
    bool forceRefresh = false,
  }) async {
    // Check if we have valid cached data
    if (!forceRefresh &&
        _cachedData != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheValidDuration) {
      return _cachedData!;
    }

    // Fetch fresh data
    _cachedData = await _service.getCompleteWeatherData();
    _lastFetch = DateTime.now();

    return _cachedData!;
  }

  /// Clear cached data
  static void clearCache() {
    _cachedData = null;
    _lastFetch = null;
  }

  /// Get cached data without fetching
  static WeatherLocationData? getCachedData() {
    return _cachedData;
  }
}
