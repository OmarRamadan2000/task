import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../models/network_device_model.dart';

abstract class DeviceDataSource {
  Future<List<NetworkDeviceModel>> scanDevices();
  Future<void> connectToDevice(String deviceId);
}

class DeviceDataSourceImpl implements DeviceDataSource {
  final NetworkInfo networkInfo;

  DeviceDataSourceImpl({required this.networkInfo});

  @override
  Future<List<NetworkDeviceModel>> scanDevices() async {
    List<NetworkDeviceModel> devices = [];

    try {
      // Get WiFi info
      await _addWifiDevices(devices);

      // Get Bluetooth devices
      await _addBluetoothDevices(devices);

      return devices;
    } catch (e) {
      throw PermissionException('Failed to scan devices: ${e.toString()}');
    }
  }

  Future<void> _addWifiDevices(List<NetworkDeviceModel> devices) async {
    try {
      final wifiName = await networkInfo.getWifiName();
      final wifiBSSID = await networkInfo.getWifiBSSID();
      final wifiIP = await networkInfo.getWifiIP();

      if (wifiName != null && wifiName.isNotEmpty) {
        devices.add(
          NetworkDeviceModel(
            id: wifiBSSID ?? 'wifi_default',
            name: '$wifiName${wifiIP != null ? " ($wifiIP)" : ""}',
            type: 'wifi',
            isConnected: true,
          ),
        );
      }
    } catch (e) {
      // WiFi info might not be available, continue
    }
  }

  Future<void> _addBluetoothDevices(List<NetworkDeviceModel> devices) async {
    try {
      // Check permissions
      if (Platform.isAndroid) {
        final bluetoothScan = await Permission.bluetoothScan.request();
        final bluetoothConnect = await Permission.bluetoothConnect.request();
        final location = await Permission.location.request();

        if (!bluetoothScan.isGranted ||
            !bluetoothConnect.isGranted ||
            !location.isGranted) {
          return;
        }
      } else if (Platform.isIOS) {
        final bluetooth = await Permission.bluetooth.request();
        if (!bluetooth.isGranted) {
          return;
        }
      }

      // Check if Bluetooth is available
      final isAvailable = await FlutterBluePlus.isAvailable;
      if (!isAvailable) {
        return;
      }

      // Check if Bluetooth is on
      final isOn = await FlutterBluePlus.isOn;
      if (!isOn) {
        return;
      }

      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      // Get scan results
      final results = FlutterBluePlus.scanResults;
      await for (final r in results) {
        for (final result in r) {
          final device = result.device;
          final name = device.platformName.isNotEmpty
              ? device.platformName
              : 'Unknown Device';

          // Add unique devices only
          if (!devices.any((d) => d.id == device.remoteId.toString())) {
            devices.add(
              NetworkDeviceModel(
                id: device.remoteId.toString(),
                name: name,
                type: 'bluetooth',
                isConnected: false,
              ),
            );
          }
        }
      }

      // Stop scanning
      await FlutterBluePlus.stopScan();
    } catch (e) {
      // Bluetooth might not be available, continue
    }
  }

  @override
  Future<void> connectToDevice(String deviceId) async {
    try {
      // For now, this is a placeholder
      // In a real app, you would implement actual device connection logic
      // For Bluetooth: find device and connect
      // For WiFi: configure network settings
      // For Printer: establish printer connection
    } catch (e) {
      throw PermissionException('Failed to connect to device');
    }
  }
}
