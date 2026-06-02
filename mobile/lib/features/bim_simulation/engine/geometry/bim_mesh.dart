import 'dart:math' as math;

import '../math/bim_vec3.dart';

/// Procedural mesh primitive with triangle faces and BIM edge lines.
class BimMesh {
  BimMesh({
    required this.vertices,
    required this.indices,
    this.edges = const [],
  });

  final List<BimVec3> vertices;
  final List<int> indices;
  final List<(int, int)> edges;

  static BimMesh box({
    required double width,
    required double height,
    required double depth,
    BimVec3 center = BimVec3.zero,
  }) {
    final hw = width / 2;
    final hh = height / 2;
    final hd = depth / 2;
    final cx = center.x;
    final cy = center.y;
    final cz = center.z;

    final v = [
      BimVec3(cx - hw, cy, cz - hd),
      BimVec3(cx + hw, cy, cz - hd),
      BimVec3(cx + hw, cy, cz + hd),
      BimVec3(cx - hw, cy, cz + hd),
      BimVec3(cx - hw, cy + height, cz - hd),
      BimVec3(cx + hw, cy + height, cz - hd),
      BimVec3(cx + hw, cy + height, cz + hd),
      BimVec3(cx - hw, cy + height, cz + hd),
    ];

    const faces = [
      [0, 1, 2, 0, 2, 3],
      [4, 6, 5, 4, 7, 6],
      [0, 4, 5, 0, 5, 1],
      [1, 5, 6, 1, 6, 2],
      [2, 6, 7, 2, 7, 3],
      [3, 7, 4, 3, 4, 0],
    ];

    final indices = <int>[];
    for (final f in faces) {
      indices.addAll(f);
    }

    final edges = <(int, int)>{
      (0, 1), (1, 2), (2, 3), (3, 0),
      (4, 5), (5, 6), (6, 7), (7, 4),
      (0, 4), (1, 5), (2, 6), (3, 7),
    }.toList();

    return BimMesh(vertices: v, indices: indices, edges: edges);
  }

  static BimMesh cylinder({
    required double radius,
    required double height,
    int segments = 16,
    BimVec3 base = BimVec3.zero,
  }) {
    final vertices = <BimVec3>[];
    final indices = <int>[];
    final edges = <(int, int)>[];

    for (var i = 0; i <= segments; i++) {
      final t = i / segments * 2 * math.pi;
      final x = math.cos(t) * radius;
      final z = math.sin(t) * radius;
      vertices.add(BimVec3(base.x + x, base.y, base.z + z));
      vertices.add(BimVec3(base.x + x, base.y + height, base.z + z));
    }

    for (var i = 0; i < segments; i++) {
      final a = i * 2;
      final b = a + 1;
      final c = a + 2;
      final d = a + 3;
      indices.addAll([a, c, b, b, c, d]);
      edges.add((a, c));
      edges.add((b, d));
    }

    return BimMesh(vertices: vertices, indices: indices, edges: edges);
  }
}
