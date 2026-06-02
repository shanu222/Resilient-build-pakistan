import 'package:flutter_test/flutter_test.dart';
import 'package:resilientbuild_pakistan/features/bim/engineering/engineering_constraint_solver.dart';
import 'package:resilientbuild_pakistan/features/bim/engineering/engineering_model_generator.dart';
import 'package:resilientbuild_pakistan/features/bim_simulation/engine/bim_scene_registry.dart';

void main() {
  test('all procedural BIM models pass engineering QC after centroid normalize', () {
    final failures = <String, List<String>>{};

    for (final modelId in BimSceneRegistry.bimModelIds) {
      final pkg = BimSceneRegistry.packageFor(modelId);
      final result = EngineeringModelGenerator.generate(pkg);
      if (!result.validation.passed) {
        failures[modelId] = result.validation.errors;
      }
    }

    if (failures.isNotEmpty) {
      final buf = StringBuffer('Constraint validation failures:\n');
      for (final e in failures.entries) {
        buf.writeln('  ${e.key}: ${e.value.join('; ')}');
      }
      fail(buf.toString());
    }
  });
}
