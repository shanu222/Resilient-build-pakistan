import 'package:cloud_firestore/cloud_firestore.dart';

/// Remote content layer for NDMA admin updates without app redeploy.
/// Collections: houses, materials, regions, hazards, construction_simulations.
class FirebaseAdminRepository {
  FirebaseAdminRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<Map<String, dynamic>>> watchHouses() {
    return _db.collection('houses').snapshots().map(
          (snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList(),
        );
  }

  Future<List<Map<String, dynamic>>> fetchHousesOnce() async {
    final snap = await _db.collection('houses').get();
    return snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
  }

  Stream<List<Map<String, dynamic>>> watchRegions() {
    return _db.collection('regions').snapshots().map(
          (snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList(),
        );
  }

  Future<void> seedFromJsonIfEmpty({
    required List<Map<String, dynamic>> houses,
  }) async {
    final existing = await _db.collection('houses').limit(1).get();
    if (existing.docs.isNotEmpty) return;
    final batch = _db.batch();
    for (final house in houses) {
      final id = house['id'] as String;
      final ref = _db.collection('houses').doc(id);
      batch.set(ref, house);
    }
    await batch.commit();
  }
}
