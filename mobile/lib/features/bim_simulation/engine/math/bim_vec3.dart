import 'dart:math' as math;

class BimVec3 {
  const BimVec3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const zero = BimVec3(0, 0, 0);

  BimVec3 operator +(BimVec3 o) => BimVec3(x + o.x, y + o.y, z + o.z);
  BimVec3 operator -(BimVec3 o) => BimVec3(x - o.x, y - o.y, z - o.z);
  BimVec3 operator *(double s) => BimVec3(x * s, y * s, z * s);

  double dot(BimVec3 o) => x * o.x + y * o.y + z * o.z;
  BimVec3 cross(BimVec3 o) => BimVec3(
        y * o.z - z * o.y,
        z * o.x - x * o.z,
        x * o.y - y * o.x,
      );

  double get length => math.sqrt(x * x + y * y + z * z);
  BimVec3 normalized() {
    final l = length;
    if (l == 0) return this;
    return BimVec3(x / l, y / l, z / l);
  }
}

class BimAabb {
  const BimAabb(this.min, this.max);

  final BimVec3 min;
  final BimVec3 max;

  BimVec3 get center =>
      BimVec3((min.x + max.x) / 2, (min.y + max.y) / 2, (min.z + max.z) / 2);
}
