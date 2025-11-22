import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _urlController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadSettings();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SettingsSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() => _isEditing = false);
            // After a brief moment, pop back to previous screen so Home can refresh
            Future.delayed(const Duration(milliseconds: 450), () {
              if (mounted) Navigator.pop(context);
            });
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsLoaded || state is SettingsSaved) {
            final settings = state is SettingsLoaded
                ? state.settings
                : (state as SettingsSaved).settings;
            final devices = state is SettingsLoaded ? state.devices : [];
            final isScanning = state is SettingsLoaded
                ? state.isScanning
                : false;

            if (!_isEditing && _urlController.text.isEmpty) {
              _urlController.text = settings.webUrl;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Web URL Section
                  _buildSectionTitle('Web URL'),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _urlController,
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'Website URL',
                              hintText: 'https://example.com',
                              prefixIcon: const Icon(Icons.link),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: !_isEditing,
                              fillColor: _isEditing
                                  ? null
                                  : Colors.grey.shade100,
                            ),
                            keyboardType: TextInputType.url,
                            onChanged: (_) {
                              setState(() => _isEditing = true);
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_isEditing)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _urlController.text = settings.webUrl;
                                        _isEditing = false;
                                      });
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_urlController.text.isNotEmpty) {
                                        context
                                            .read<SettingsCubit>()
                                            .updateWebUrl(_urlController.text);
                                      }
                                    },
                                    child: const Text('Save'),
                                  ),
                                ),
                              ],
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => _isEditing = true);
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit URL'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Network Devices Section
                  _buildSectionTitle('Network Devices'),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Available Devices',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (isScanning)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                IconButton(
                                  onPressed: () {
                                    context.read<SettingsCubit>().scanDevices();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  tooltip: 'Scan devices',
                                ),
                            ],
                          ),
                          const Divider(),
                          if (devices.isEmpty && !isScanning)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.devices_other,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No devices found',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: () {
                                        context
                                            .read<SettingsCubit>()
                                            .scanDevices();
                                      },
                                      icon: const Icon(Icons.search),
                                      label: const Text('Scan Now'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            DropdownButtonFormField<String>(
                              value: settings.selectedDeviceId,
                              decoration: InputDecoration(
                                labelText: 'Select Device',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.devices),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('None'),
                                ),
                                ...devices.map((device) {
                                  return DropdownMenuItem(
                                    value: device.id,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getDeviceIcon(device.type),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(device.name)),
                                        if (device.isConnected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                context.read<SettingsCubit>().selectDevice(
                                  value,
                                );
                              },
                            ),
                          const SizedBox(height: 12),
                          Text(
                            'Connect to WiFi, Bluetooth, or printer devices',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Failed to load settings'));
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  IconData _getDeviceIcon(String type) {
    switch (type) {
      case 'wifi':
        return Icons.wifi;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'printer':
        return Icons.print;
      default:
        return Icons.device_unknown;
    }
  }
}
