import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:io' show Platform;
import 'dart:async';

class ARViewScreen extends StatefulWidget {
  const ARViewScreen({super.key});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  final List<String> _models = [
    'chair.glb',
    'sofa.glb',
    'table.glb',
    'lamp.glb',
  ];

  String _currentModel = 'chair.glb';
  bool _isLoading = false;
  bool _autoRotate = true;
  bool _isARAvailable = true;
  String? _errorMessage;
  bool _hasModelError = false;

  @override
  void initState() {
    super.initState();
    _checkARAvailability();
  }

  Future<void> _checkARAvailability() async {
    try {
      if (Platform.isAndroid) {
        // For Android, we'll assume AR is available if the device is running Android 7.0 or higher
        _isARAvailable = true;
      } else if (Platform.isIOS) {
        // For iOS, we'll assume AR is available if the device is running iOS 11.0 or higher
        _isARAvailable = true;
      }
    } catch (e) {
      setState(() {
        _isARAvailable = false;
        _errorMessage = 'AR is not available on this device: $e';
      });
    }
  }

  void _handleModelError() {
    setState(() {
      _hasModelError = true;
      _errorMessage = 'Error loading 3D model. Please try again.';
    });
  }

  Widget _buildModelViewer() {
    if (_hasModelError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Error loading model',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasModelError = false;
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return ModelViewer(
      backgroundColor: const Color(0xFF242424),
      src: 'assets/models/$_currentModel',
      alt: '3D Furniture Model',
      ar: true,
      arModes: const ['scene-viewer', 'webxr'],
      autoRotate: _autoRotate,
      cameraControls: true,
      loading: Loading.eager,
      arPlacement: ArPlacement.floor,
      arScale: ArScale.fixed,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isARAvailable) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AR Not Available'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'AR is not available on this device',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AR Furniture Viewer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _autoRotate ? Icons.rotate_right : Icons.rotate_right_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _autoRotate = !_autoRotate;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildModelViewer(),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Model selection
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      itemCount: _models.length,
                      itemBuilder: (context, index) {
                        final model = _models[index];
                        final isSelected = model == _currentModel;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentModel = model;
                              _isLoading = true;
                              _hasModelError = false;
                            });
                            // Add a small delay to show loading state
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              setState(() {
                                _isLoading = false;
                              });
                            });
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isSelected ? Colors.white : Colors.white24,
                                width: 2,
                              ),
                              color: Colors.white12,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getIconForModel(model),
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  size: 32,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getModelName(model),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _isLoading = true;
            _hasModelError = false;
          });
          // Add a small delay to show loading state
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tap the screen to place the furniture in AR'),
                duration: Duration(seconds: 2),
              ),
            );
          });
        },
        icon: const Icon(Icons.view_in_ar),
        label: const Text('Place in Room'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  IconData _getIconForModel(String model) {
    switch (model) {
      case 'chair.glb':
        return Icons.chair;
      case 'sofa.glb':
        return Icons.weekend;
      case 'table.glb':
        return Icons.table_restaurant;
      case 'lamp.glb':
        return Icons.light;
      default:
        return Icons.view_in_ar;
    }
  }

  String _getModelName(String model) {
    return model.split('.').first.capitalize();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
