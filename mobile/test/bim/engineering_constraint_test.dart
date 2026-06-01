import 'package:flutter_test/flutter_test.dart';
import 'package:resilientbuild_pakistan/features/bim/engineering_constraint_engine.dart';
import 'package:resilientbuild_pakistan/features/bim_simulation/engine/bim_scene_registry.dart';

void main() {
  test('all 16 procedural BIM models pass engineering constraint validation', () {
    final failures = <String, List<String>>{};

    for (final modelId in BimSceneRegistry.bimModelIds) {
      final pkg = BimSceneRegistry.packageFor(modelId);
      final entities = pkg.buildScene();
      final result = EngineeringConstraintEngine.validate(entities);
      if (!result.passed) {
        failures[modelId] = result.errors;
      }
    }

    if (failures.isNotEmpty) {
      final buf = StringBuffer('Constraint validation failures:\n');
      for (final e in failures.entries) {
        buf.writeln('  $e.key: ${e.value.join('; ')}');
      }
      fail(buf.toString());
    }
  });
}
