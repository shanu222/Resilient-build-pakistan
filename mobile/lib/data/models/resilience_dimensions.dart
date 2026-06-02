import 'package:equatable/equatable.dart';

class ResilienceDimensions extends Equatable {
  const ResilienceDimensions({
    required this.floodResistance,
    required this.earthquakeResistance,
    required this.landslideResistance,
    required this.windResistance,
    required this.moistureResistance,
    required this.thermalEfficiency,
  });

  factory ResilienceDimensions.fromJson(Map<String, dynamic> json) {
    return ResilienceDimensions(
      floodResistance: json['floodResistance'] as int? ?? 60,
      earthquakeResistance: json['earthquakeResistance'] as int? ?? 75,
      landslideResistance: json['landslideResistance'] as int? ?? 65,
      windResistance: json['windResistance'] as int? ?? 72,
      moistureResistance: json['moistureResistance'] as int? ?? 68,
      thermalEfficiency: json['thermalEfficiency'] as int? ?? 70,
    );
  }

  final int floodResistance;
  final int earthquakeResistance;
  final int landslideResistance;
  final int windResistance;
  final int moistureResistance;
  final int thermalEfficiency;

  int get overall => ((floodResistance +
              earthquakeResistance +
              landslideResistance +
              windResistance +
              moistureResistance +
              thermalEfficiency) /
          6)
      .round();

  List<MapEntry<String, int>> get entries => [
        MapEntry('Flood Resistance', floodResistance),
        MapEntry('Earthquake Resistance', earthquakeResistance),
        MapEntry('Landslide Resistance', landslideResistance),
        MapEntry('Wind Resistance', windResistance),
        MapEntry('Moisture Resistance', moistureResistance),
        MapEntry('Thermal Efficiency', thermalEfficiency),
      ];

  @override
  List<Object?> get props => [
        floodResistance,
        earthquakeResistance,
        landslideResistance,
        windResistance,
        moistureResistance,
        thermalEfficiency,
      ];
}
