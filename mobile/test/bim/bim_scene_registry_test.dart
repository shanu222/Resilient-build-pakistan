import 'package:flutter_test/flutter_test.dart';
import 'package:resilientbuild_pakistan/features/bim_simulation/engine/bim_scene_registry.dart';
import 'package:resilientbuild_pakistan/features/models/resilient_model_registry.dart';

void main() {
  test('core 16 models except bamboo have BIM', () {
    for (final id in ResilientModelRegistry.coreModelIds) {
      if (id == 'bamboo_frame_wattle_daub') {
        expect(BimSceneRegistry.hasBimSimulation(id), isFalse);
      } else {
        expect(
          BimSceneRegistry.hasBimSimulation(id),
          isTrue,
          reason: '$id should have BIM',
        );
      }
    }
  });

  test('definitionAssetFor returns JSON path', () {
    final path = BimSceneRegistry.definitionAssetFor('earthbag_masonry');
    expect(path, contains('bim_'));
    expect(path, endsWith('.json'));
  });
}
