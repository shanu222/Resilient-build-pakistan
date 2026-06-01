import '../bim_simulation/engine/bim_visualization_mode.dart';

/// Engineering inspection content for BIM component selection.
abstract final class BimComponentInspection {
  static Map<String, dynamic> docFor(String? componentId, Map<String, dynamic> docs) {
    if (componentId == null) return {};
    final raw = docs[componentId];
    if (raw is Map<String, dynamic>) {
      return {
        ...raw,
        ..._extended(componentId),
      };
    }
    return _extended(componentId);
  }

  static Map<String, dynamic> _extended(String id) {
    final base = _catalog[id] ?? _catalog['foundation']!;
    return Map<String, dynamic>.from(base);
  }

  static const _catalog = <String, Map<String, dynamic>>{
    'foundation': {
      'title': 'Foundation',
      'function': 'Transfers building loads to competent bearing soil.',
      'loads': 'Vertical gravity, lateral seismic, uplift (wind).',
      'inspection': 'Rebar cover, lap lengths, bearing capacity, levelness.',
      'failures': 'Insufficient depth, soft bearing, discontinuous footings.',
      'notes': 'Excavate to firm stratum; compact base; cure before walls.',
    },
    'column': {
      'title': 'Column / Vertical Support',
      'function': 'Carries vertical loads from beams/roof to foundation.',
      'loads': 'Axial compression, minor bending from eccentricity.',
      'inspection': 'Verticality, plumb, base plate/grout, continuity.',
      'failures': 'Floating columns, short lap splices, honeycombing.',
      'notes': 'Align to grid; tie to plinth beam before wall construction.',
    },
    'beam': {
      'title': 'Beam / Band',
      'function': 'Ties walls and columns; distributes lateral loads.',
      'loads': 'Bending, shear, torsion at corners.',
      'inspection': 'Continuous pour at corners, anchorage, level.',
      'failures': 'Cold joints, missing corner continuity, inadequate cover.',
      'notes': 'Seismic bands must form closed horizontal loop.',
    },
    'wall': {
      'title': 'Wall System',
      'function': 'Enclosure, lateral resistance, load bearing.',
      'loads': 'Gravity, in-plane shear, out-of-plane wind.',
      'inspection': 'Bond, verticality, openings framed, DPC continuity.',
      'failures': 'Misaligned courses, weak corners, no lintels.',
      'notes': 'Build plumb; stagger joints; integrate bands at lintel level.',
    },
    'roof': {
      'title': 'Roof / Diaphragm',
      'function': 'Weather protection; diaphragm tying walls together.',
      'loads': 'Gravity, wind uplift, seismic inertia.',
      'inspection': 'Anchors, waterproofing, slope, truss connections.',
      'failures': 'Inadequate wall ties, ponding, missing bracing.',
      'notes': 'Complete diaphragm before occupancy; test drainage.',
    },
    'drainage': {
      'title': 'Drainage',
      'function': 'Removes surface and subsurface water from structure.',
      'loads': 'Hydraulic pressure relief.',
      'inspection': 'Slope, outlet capacity, filter layers, weep holes.',
      'failures': 'Blocked drains, backfall, saturated foundation soils.',
      'notes': 'Daylight drains away from footings; protect plinth toe.',
    },
    'reinforcement': {
      'title': 'Reinforcement',
      'function': 'Provides tensile capacity in masonry/concrete systems.',
      'loads': 'Tension, shear, confinement.',
      'inspection': 'Cover, spacing, laps, ties, corrosion protection.',
      'failures': 'Insufficient lap length, missing stirrups, exposed rebar.',
      'notes': 'Place before pour; maintain cover blocks during placement.',
    },
  };

  static BimVisualizationMode modeForToolbar(String action) => switch (action) {
        'structural' => BimVisualizationMode.structural,
        'load' => BimVisualizationMode.loadTransfer,
        'explode' => BimVisualizationMode.exploded,
        'section' => BimVisualizationMode.normal,
        'connection' => BimVisualizationMode.connection,
        'earthquake' => BimVisualizationMode.earthquake,
        'flood' => BimVisualizationMode.flood,
        'wind' => BimVisualizationMode.normal,
        _ => BimVisualizationMode.normal,
      };
}
