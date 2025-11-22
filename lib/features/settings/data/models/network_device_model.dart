import '../../domain/entities/network_device.dart';

class NetworkDeviceModel extends NetworkDevice {
  const NetworkDeviceModel({
    required super.id,
    required super.name,
    required super.type,
    super.isConnected,
  });

  factory NetworkDeviceModel.fromMap(Map<String, dynamic> map) {
    return NetworkDeviceModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      isConnected: map['isConnected'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'type': type, 'isConnected': isConnected};
  }
}
