import 'package:equatable/equatable.dart';

class NetworkDevice extends Equatable {
  final String id;
  final String name;
  final String type; // 'wifi', 'bluetooth', 'printer'
  final bool isConnected;

  const NetworkDevice({
    required this.id,
    required this.name,
    required this.type,
    this.isConnected = false,
  });

  @override
  List<Object> get props => [id, name, type, isConnected];

  NetworkDevice copyWith({
    String? id,
    String? name,
    String? type,
    bool? isConnected,
  }) {
    return NetworkDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
