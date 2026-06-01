import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../bim/camera_controller_pro.dart';
import '../../bim/construction_assembly_animator.dart';
import '../../bim/engineering_constraint_engine.dart';
import 'bim_entity.dart';
import 'bim_scene_package.dart';
import 'bim_scene_registry.dart';
import 'bim_visualization_mode.dart';
import 'geometry/amphibious_dimensions.dart';
import 'math/bim_vec3.dart';
import 'rendering/bim_camera.dart';
import 'rendering/bim_picker.dart';
import 'rendering/bim_scene_bounds.dart';

class BimStageDefinition {
  BimStageDefinition({
    required this.index,
    required this.key,
    required this.title,
    required this.timelineLabel,
    required this.durationMs,
    required this.narration,
    required this.explanation,
    required this.highlights,
  });

  factory BimStageDefinition.fromJson(Map<String, dynamic> j) {
    return BimStageDefinition(
      index: j['index'] as int,
      key: j['key'] as String,
      title: j['title'] as String,
      timelineLabel: j['timelineLabel'] as String,
      durationMs: j['durationMs'] as int,
      narration: j['narration'] as String,
      explanation: j['explanation'] as String,
      highlights: List<String>.from(j['highlights'] as List),
    );
  }

  final int index;
  final String key;
  final String title;
  final String timelineLabel;
  final int durationMs;
  final String narration;
  final String explanation;
  final List<String> highlights;
}

class BimSimulationController extends ChangeNotifier {
  BimSimulationController({String modelId = 'interlocking_brick_masonry'}) {
    _package = BimSceneRegistry.packageFor(modelId);
    this.modelId = _package.modelId;
    displayName = _package.displayName;
    _entities = _package.buildScene();
    _validateScene();
    _fitCameraToScene();
  }

  final cameraPro = CameraControllerPro();
  BimCamera get camera => cameraPro.camera;

  ConstraintValidationResult? validationResult;
  bool showStructuralGrid = false;
  bool assemblyAnimationEnabled = true;
  late final BimScenePackage _package;
  BimVec3 _sceneCenter = BimVec3.zero;
  double _sceneRadius = 8;
  late List<BimEntity> _entities;

  BimVec3 get sceneCenter => _sceneCenter;
  double get sceneRadius => _sceneRadius;

  String modelId = '';
  String displayName = '';

  List<BimStageDefinition> stages = [];
  Map<String, dynamic> componentDocs = {};
  Map<String, dynamic> resilienceSummary = {};

  int stageIndex = 0;
  double stageProgress = 0;
  bool isPlaying = false;
  double playbackSpeed = 1.0;
  BimVisualizationMode viewMode = BimVisualizationMode.normal;
  bool crossSectionEnabled = false;
  String? selectedComponentId;
  double earthquakePhase = 0;
  double floodPhase = 0;
  double thermalPhase = 0;
  double landslidePhase = 0;
  double modularPhase = 0;
  double blockAssemblyPhase = 0;
  double materialComparisonPhase = 0;

  List<BimEntity> get entities => _entities;
  BimStageDefinition? get currentStage =>
      stages.isEmpty ? null : stages[stageIndex.clamp(0, stages.length - 1)];

  Future<void> loadDefinition() async {
    final raw = await rootBundle.loadString(_package.definitionAssetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    stages = (json['stages'] as List)
        .map((e) => BimStageDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
    componentDocs = json['components'] as Map<String, dynamic>;
    resilienceSummary = json['resilienceSummary'] as Map<String, dynamic>;
    _applyStageVisibility();
    _fitCameraToScene();
    notifyListeners();
  }

  void _validateScene() {
    validationResult = EngineeringConstraintEngine.validate(_entities);
  }

  void _fitCameraToScene({double? viewportWidth}) {
    final bounds = BimSceneBounds.fromEntities(_entities);
    _sceneCenter = bounds.center;
    _sceneRadius = bounds.radius;
    cameraPro.fitToBounds(bounds, viewportWidth: viewportWidth);
  }

  void fitCamera({double? viewportWidth, double? viewportHeight}) {
    final bounds = BimSceneBounds.fromEntities(_entities);
    cameraPro.fitToBounds(
      bounds,
      viewportWidth: viewportWidth,
      viewportHeight: viewportHeight,
    );
    notifyListeners();
  }

  void toggleStructuralGrid() {
    showStructuralGrid = !showStructuralGrid;
    notifyListeners();
  }

  BimVec3 assemblyOffset(BimEntity e) {
    if (!assemblyAnimationEnabled) return BimVec3.zero;
    return ConstructionAssemblyAnimator.assemblyOffset(e, e.buildProgress);
  }

  void setStage(int index, {double progress = 0}) {
    stageIndex = index.clamp(0, stages.length - 1);
    stageProgress = progress.clamp(0.0, 1.0);
    _applyStageVisibility();
    notifyListeners();
  }

  void setScrub(double globalProgress) {
    if (stages.isEmpty) return;
    final total = stages.length;
    final pos = globalProgress.clamp(0.0, 0.999) * total;
    stageIndex = pos.floor().clamp(0, total - 1);
    stageProgress = pos - stageIndex;
    _applyStageVisibility();
    notifyListeners();
  }

  double get globalProgress =>
      stages.isEmpty ? 0 : (stageIndex + stageProgress) / stages.length;

  void tick(double dt) {
    if (!isPlaying || stages.isEmpty) return;
    final stage = currentStage!;
    final step = dt / (stage.durationMs / playbackSpeed);
    stageProgress += step;
    if (stageProgress >= 1) {
      stageProgress = 0;
      if (stageIndex < stages.length - 1) {
        stageIndex++;
      } else {
        isPlaying = false;
        stageProgress = 1;
      }
    }
    if (stageIndex == stages.length - 1) {
      camera.autoOrbit(stageProgress * 3.14);
    }
    _applyStageVisibility();
    notifyListeners();
  }

  void advanceEnvironmentalEffects(double dt) {
    earthquakePhase += dt * 5;
    if (viewMode == BimVisualizationMode.flood ||
        viewMode == BimVisualizationMode.buoyancy) {
      if (isElevatedFlood || isAmphibious || isRaisedPlinth) {
        floodPhase += dt * (viewMode == BimVisualizationMode.buoyancy ? 2 : 3);
        _applyViewModeFilters();
        notifyListeners();
      }
    }
    if (viewMode == BimVisualizationMode.drainage && isRaisedPlinth) {
      floodPhase += dt * 2.2;
      _applyViewModeFilters();
      notifyListeners();
    }
    if (viewMode == BimVisualizationMode.thermal &&
        (isFlyAsh ||
            isPrefabricated ||
            isRatTrapBond ||
            isReinforcedAdobe)) {
      thermalPhase += dt * 2.5;
      _applyViewModeFilters();
      notifyListeners();
    }
    if (viewMode == BimVisualizationMode.cavityWall && isRatTrapBond) {
      thermalPhase += dt * 2;
      _applyViewModeFilters();
      notifyListeners();
    }
    if (viewMode == BimVisualizationMode.materialComparison && isRatTrapBond) {
      materialComparisonPhase += dt * 1.8;
      _applyViewModeFilters();
      notifyListeners();
    }
    if (viewMode == BimVisualizationMode.modularAssembly && isPrefabricated) {
      modularPhase += dt * 1.6;
      _applyViewModeFilters();
      notifyListeners();
    }
    if (viewMode == BimVisualizationMode.blockAssembly &&
        isAdvancedInterlocking) {
      blockAssemblyPhase += dt * 1.5;
      _applyViewModeFilters();
      notifyListeners();
    }
    if (isGeogrid &&
        (viewMode == BimVisualizationMode.landslide ||
            viewMode == BimVisualizationMode.earthPressure ||
            viewMode == BimVisualizationMode.groundwater)) {
      landslidePhase += dt * 2.2;
      _applyViewModeFilters();
      notifyListeners();
    }
  }

  void togglePlay() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void setPlaybackSpeed(double s) {
    playbackSpeed = s.clamp(0.5, 2.0);
    notifyListeners();
  }

  void setViewMode(BimVisualizationMode mode) {
    viewMode = mode;
    _applyViewModeFilters();
    notifyListeners();
  }

  void toggleCrossSection() {
    crossSectionEnabled = !crossSectionEnabled;
    notifyListeners();
  }

  void selectAt(Offset screenPos, Size size) {
    selectedComponentId =
        BimPicker.pickComponent(screenPos, size, _entities, camera);
    notifyListeners();
  }

  void _applyStageVisibility() {
    final si = stageIndex;
    final p = stageProgress;

    for (final e in _entities) {
      if (e.minStage > si) {
        e.visible = false;
        e.buildProgress = 0;
        continue;
      }
      if (e.minStage < si) {
        e.visible = true;
        e.buildProgress = 1;
        continue;
      }
      e.visible = true;
      e.buildProgress = _package.entityProgress(e, si, p);
    }

    _applyViewModeFilters();
  }

  void _applyViewModeFilters() {
    for (final e in _entities) {
      if (!e.visible) continue;
      switch (viewMode) {
        case BimVisualizationMode.rebar:
          if (isReinforcedAdobe) {
            _applyAdobeReinforcementViewFilters(e);
          } else {
            e.opacity = e.category == BimEntityCategory.rebar ? 1 : 0.1;
          }
        case BimVisualizationMode.reinforcement:
          _applyAdobeReinforcementViewFilters(e);
        case BimVisualizationMode.structural:
          e.opacity = [
            BimEntityCategory.masonry,
            BimEntityCategory.concrete,
            BimEntityCategory.rebar,
            BimEntityCategory.earthbag,
            BimEntityCategory.wire,
            BimEntityCategory.timber,
            BimEntityCategory.bamboo,
          ].contains(e.category)
              ? 1
              : 0.12;
        case BimVisualizationMode.sequence:
          e.opacity = e.minStage <= stageIndex ? 1 : 0.18;
        case BimVisualizationMode.drainage:
          if (isRaisedPlinth) {
            _applyRaisedPlinthDrainageFilters(e);
          } else if (isGeogrid) {
            e.opacity = e.category == BimEntityCategory.drainage ||
                    e.id.contains('drainage') ||
                    e.id.contains('weep') ||
                    e.id == 'filter_layer' ||
                    e.id == 'groundwater_table'
                ? 1
                : 0.18;
          } else {
            e.opacity = [
              BimEntityCategory.drainage,
              BimEntityCategory.terrain,
              BimEntityCategory.excavation,
            ].contains(e.category)
                ? 1
                : 0.25;
          }
        case BimVisualizationMode.bambooFrame:
          e.opacity = [
            BimEntityCategory.bamboo,
            BimEntityCategory.wire,
            BimEntityCategory.timber,
          ].contains(e.category)
              ? 1
              : 0.15;
        case BimVisualizationMode.steelFrame:
          _applySteelFrameViewFilters(e);
        case BimVisualizationMode.connection:
          _applyConnectionViewFilters(e);
        case BimVisualizationMode.timberBand:
          _applyTimberBandViewFilters(e);
        case BimVisualizationMode.timberSkeleton:
          _applyTimberSkeletonViewFilters(e);
        case BimVisualizationMode.flood:
          _applyFloodViewFilters(e);
        case BimVisualizationMode.buoyancy:
          _applyBuoyancyViewFilters(e);
        case BimVisualizationMode.thermal:
          _applyThermalViewFilters(e);
        case BimVisualizationMode.modularAssembly:
          _applyModularAssemblyViewFilters(e);
        case BimVisualizationMode.blockAssembly:
          _applyBlockAssemblyViewFilters(e);
        case BimVisualizationMode.cavityWall:
          _applyCavityWallViewFilters(e);
        case BimVisualizationMode.materialComparison:
          _applyMaterialComparisonViewFilters(e);
        case BimVisualizationMode.earthPressure:
          _applyEarthPressureViewFilters(e);
        case BimVisualizationMode.landslide:
          _applyLandslideViewFilters(e);
        case BimVisualizationMode.groundwater:
          _applyGroundwaterViewFilters(e);
        case BimVisualizationMode.hydraulic:
          if (isAmphibious) {
            e.opacity = e.id.contains('river') ||
                    e.id.contains('flood') ||
                    e.id.startsWith('guide_post') ||
                    e.id.startsWith('buoy') ||
                    e.id.startsWith('flex_') ||
                    e.category == BimEntityCategory.drainage
                ? 1
                : 0.18;
          } else {
            e.opacity = [
              BimEntityCategory.drainage,
              BimEntityCategory.excavation,
              BimEntityCategory.masonry,
              BimEntityCategory.concrete,
            ].contains(e.category) ||
                    e.id.contains('scour') ||
                    e.id.contains('riprap') ||
                    e.id.contains('river')
                ? 1
                : 0.2;
          }
        case BimVisualizationMode.earthquake:
        case BimVisualizationMode.seismic:
          if (isReinforcedAdobe) {
            _applyAdobeEarthquakeViewFilters(e);
          } else if (isTimberFrameLath) {
            _applyTimberFrameEarthquakeViewFilters(e);
          } else if (isAdvancedInterlocking) {
            _applyAdvancedInterlockingEarthquakeViewFilters(e);
          } else {
            e.opacity = 1;
          }
        default:
          e.opacity = 1;
      }
    }
  }

  void _applyFloodViewFilters(BimEntity e) {
    final waterLevel = 0.35 + 0.45 * ((math.sin(floodPhase) + 1) / 2);
    if (e.id == 'flood_water') {
      e.opacity = isAmphibious ? 0.3 + waterLevel * 0.45 : waterLevel;
      e.buildProgress = isAmphibious
          ? 0.25 + waterLevel * 0.75
          : 0.4 + 0.6 * ((math.sin(floodPhase * 0.85) + 1) / 2);
      return;
    }
    if ([
      BimEntityCategory.drainage,
      BimEntityCategory.terrain,
      BimEntityCategory.excavation,
    ].contains(e.category) ||
        e.id.contains('flood') ||
        e.id.contains('scour') ||
        e.id.contains('river')) {
      e.opacity = 1;
      return;
    }
    if (isAmphibious) {
      if (e.explodeGroup == 2 || e.explodeGroup == 1) {
        e.opacity = 1;
      } else if (e.explodeGroup == 5) {
        e.opacity = 1;
      } else {
        e.opacity = 0.3;
      }
      return;
    }
    if (isRaisedPlinth) {
      if (e.explodeGroup >= 5 ||
          e.id.startsWith('wall_') ||
          e.id.startsWith('cgi_') ||
          e.id.contains('truss') ||
          e.id == 'ridge_beam' ||
          e.id == 'dpc_layer' ||
          e.id.contains('door') ||
          e.id.contains('window')) {
        e.opacity = 1;
      } else if (e.explodeGroup >= 3 ||
          e.id.startsWith('earth_fill') ||
          e.id.startsWith('plinth_beam') ||
          e.id.startsWith('retaining_edge') ||
          e.id == 'safe_level_mark') {
        e.opacity = 1;
      } else {
        e.opacity = 0.32;
      }
      return;
    }
    if (e.explodeGroup >= 3 ||
        e.id == 'elevated_slab' ||
        e.id.startsWith('wall_panel') ||
        e.id.startsWith('cgi') ||
        e.id.startsWith('truss') ||
        e.id == 'ridge_beam' ||
        e.id.startsWith('stair_landing')) {
      e.opacity = 1;
    } else {
      e.opacity = 0.35;
    }
  }

  void _applyTimberBandViewFilters(BimEntity e) {
    if (!isLohKaat) {
      e.opacity = 1;
      return;
    }
    if (e.category == BimEntityCategory.timber ||
        e.id.contains('band') ||
        e.id.contains('plinth') ||
        e.id.contains('lintel') ||
        e.id.contains('mid_band') ||
        e.id.startsWith('timber_column') ||
        e.id == 'opening_reinf') {
      e.opacity = 1;
    } else if (e.category == BimEntityCategory.masonry) {
      e.opacity = 0.12;
    } else if (e.id == 'with_band_ghost') {
      e.opacity = 0.9;
    } else {
      e.opacity = 0.08;
    }
  }

  void _applySteelFrameViewFilters(BimEntity e) {
    if (!isLightGaugeSteel) {
      e.opacity = 1;
      return;
    }
    if (e.category == BimEntityCategory.rebar ||
        e.category == BimEntityCategory.wire) {
      e.opacity = 1;
    } else if (e.category == BimEntityCategory.concrete &&
        e.explodeGroup <= 1) {
      e.opacity = 0.35;
    } else {
      e.opacity = 0.08;
    }
  }

  void _applyConnectionViewFilters(BimEntity e) {
    if (!isLightGaugeSteel) {
      e.opacity = 1;
      return;
    }
    if (e.category == BimEntityCategory.equipment ||
        e.id.contains('anchor') ||
        e.id.contains('screw') ||
        e.id.contains('gusset') ||
        e.id.contains('connector')) {
      e.opacity = 1;
    } else if (e.category == BimEntityCategory.rebar) {
      e.opacity = 0.25;
    } else {
      e.opacity = 0.1;
    }
  }

  void _applyThermalViewFilters(BimEntity e) {
    if (isPrefabricated) {
      if (e.componentId == 'insulation_core' ||
          e.id.contains('insulation') ||
          e.id == 'thermal_barrier' ||
          e.componentId == 'wall_panel' ||
          e.componentId == 'roof_panel') {
        e.opacity = 1;
      } else {
        e.opacity = 0.14;
      }
      return;
    }
    if (isReinforcedAdobe) {
      if (e.id.startsWith('adobe_brick') || e.componentId == 'adobe_brick') {
        e.opacity = 1;
      } else if (e.id == 'traditional_adobe_ghost') {
        e.opacity = 0.45;
      } else {
        e.opacity = 0.14;
      }
      return;
    }
    if (isRatTrapBond) {
      if (e.componentId == 'air_cavity' || e.id.contains('_cavity')) {
        e.opacity = 1;
      } else if (e.componentId == 'rat_trap_brick' || e.id.contains('_brick')) {
        e.opacity = 0.35;
      } else if (e.id == 'conventional_wall_ghost') {
        e.opacity = 0.55;
      } else {
        e.opacity = 0.12;
      }
      return;
    }
    if (isTimberFrameLath) {
      if (e.id.startsWith('plaster') ||
          e.id.startsWith('timber_lath') ||
          e.id == 'heavy_masonry_roof_ghost') {
        e.opacity = 1;
      } else if (e.category == BimEntityCategory.timber) {
        e.opacity = 0.35;
      } else {
        e.opacity = 0.12;
      }
      return;
    }
    if (!isFlyAsh) {
      e.opacity = 1;
      return;
    }
    if (e.componentId == 'fly_ash_brick' ||
        e.id.startsWith('fa_brick') ||
        e.category == BimEntityCategory.masonry) {
      e.opacity = 1;
    } else if (e.id == 'clay_brick_ghost') {
      e.opacity = 0.5;
    } else if (e.category == BimEntityCategory.concrete &&
        (e.id.contains('band') || e.id == 'roof_slab')) {
      e.opacity = 0.55;
    } else {
      e.opacity = 0.14;
    }
  }

  void _applyEarthPressureViewFilters(BimEntity e) {
    if (!isGeogrid) {
      e.opacity = 1;
      return;
    }
    if (e.id.startsWith('geogrid') ||
        e.id.startsWith('facing_block') ||
        e.id == 'reinforced_zone_outline' ||
        e.category == BimEntityCategory.wire ||
        e.category == BimEntityCategory.masonry) {
      e.opacity = 1;
    } else if (e.id.startsWith('backfill') ||
        e.category == BimEntityCategory.earthbag) {
      e.opacity = 0.7;
    } else {
      e.opacity = 0.12;
    }
  }

  void _applyLandslideViewFilters(BimEntity e) {
    if (!isGeogrid) {
      e.opacity = 1;
      return;
    }
    if (e.id == 'unreinforced_slope_mass') {
      e.opacity = 0.85;
    } else if (e.id.startsWith('geogrid') ||
        e.id == 'reinforced_stable_zone' ||
        e.explodeGroup >= 4) {
      e.opacity = 1;
    } else if (e.id == 'failure_surface' || e.id == 'landslide_zone') {
      e.opacity = 1;
    } else {
      e.opacity = 0.25;
    }
  }

  void _applyGroundwaterViewFilters(BimEntity e) {
    if (!isGeogrid) {
      e.opacity = 1;
      return;
    }
    if (e.id == 'groundwater_table' ||
        e.category == BimEntityCategory.drainage ||
        e.id.contains('weep')) {
      e.opacity = 1;
    } else if (e.id.startsWith('backfill')) {
      e.opacity = 0.45;
    } else {
      e.opacity = 0.15;
    }
  }

  void _applyTimberSkeletonViewFilters(BimEntity e) {
    if (!isTimberFrameLath) {
      e.opacity = 1;
      return;
    }
    if (e.category == BimEntityCategory.timber ||
        e.id.contains('truss') ||
        e.id.contains('rafter') ||
        e.id.contains('purlin') ||
        e.id == 'ridge_beam' ||
        e.id == 'plinth_beam') {
      e.opacity = 1;
    } else if (e.category == BimEntityCategory.wire) {
      e.opacity = 0.3;
    } else {
      e.opacity = 0.06;
    }
  }

  void _applyTimberFrameEarthquakeViewFilters(BimEntity e) {
    if (!isTimberFrameLath) {
      e.opacity = 1;
      return;
    }
    if (e.id == 'unbraced_frame_ghost') {
      e.opacity = 1;
      return;
    }
    if (e.id == 'plaster_crack_hint') {
      e.opacity = 0.4 + 0.6 * ((math.sin(earthquakePhase * 3) + 1) / 2);
      return;
    }
    if (e.category == BimEntityCategory.timber ||
        e.id.startsWith('brace')) {
      e.opacity = 1;
    } else if (e.id.startsWith('plaster')) {
      e.opacity = 0.75;
    } else {
      e.opacity = 0.2;
    }
  }

  void _applyAdobeReinforcementViewFilters(BimEntity e) {
    if (!isReinforcedAdobe) {
      e.opacity = 1;
      return;
    }
    if (e.category == BimEntityCategory.rebar ||
        e.category == BimEntityCategory.wire ||
        (e.id.contains('band') && e.category == BimEntityCategory.concrete)) {
      e.opacity = 1;
    } else if (e.category == BimEntityCategory.masonry) {
      e.opacity = 0.1;
    } else {
      e.opacity = 0.08;
    }
  }

  void _applyAdobeEarthquakeViewFilters(BimEntity e) {
    if (!isReinforcedAdobe) {
      e.opacity = 1;
      return;
    }
    if (e.id.startsWith('trad_crack')) {
      e.opacity = 0.35 + 0.65 * ((math.sin(earthquakePhase * 2.2) + 1) / 2);
      return;
    }
    if (e.id == 'traditional_adobe_ghost') {
      e.opacity = 1;
      return;
    }
    if (e.category == BimEntityCategory.wire ||
        e.category == BimEntityCategory.rebar ||
        e.id.contains('band')) {
      e.opacity = 1;
    } else if (e.id.startsWith('adobe_brick') ||
        e.category == BimEntityCategory.masonry) {
      e.opacity = 0.9;
    } else {
      e.opacity = 0.2;
    }
  }

  void _applyCavityWallViewFilters(BimEntity e) {
    if (!isRatTrapBond) {
      e.opacity = 1;
      return;
    }
    if (e.componentId == 'air_cavity' ||
        e.id.contains('_cavity') ||
        e.componentId == 'seismic_reinforcement' ||
        e.id.startsWith('seismic_bar')) {
      e.opacity = 1;
    } else if (e.componentId == 'rat_trap_brick' || e.id.contains('_brick')) {
      e.opacity = 0.22;
    } else if (e.id.contains('band') || e.id == 'roof_slab') {
      e.opacity = 0.45;
    } else {
      e.opacity = 0.1;
    }
  }

  void _applyMaterialComparisonViewFilters(BimEntity e) {
    if (!isRatTrapBond) {
      e.opacity = 1;
      return;
    }
    final pulse = (math.sin(materialComparisonPhase) + 1) / 2;
    if (e.id == 'conventional_wall_ghost') {
      e.opacity = 0.55 + pulse * 0.35;
      return;
    }
    if (e.id == 'material_savings_note') {
      e.opacity = 1;
      return;
    }
    if (e.id.contains('_cavity') || e.componentId == 'air_cavity') {
      e.opacity = 0.85;
    } else if (e.id.contains('_brick') || e.componentId == 'rat_trap_brick') {
      e.opacity = 1;
    } else {
      e.opacity = 0.2;
    }
  }

  void _applyRaisedPlinthDrainageFilters(BimEntity e) {
    if (e.id.contains('drain') ||
        e.category == BimEntityCategory.drainage ||
        e.id == 'runoff_arrow_note' ||
        e.id == 'river_channel') {
      e.opacity = 1;
    } else if (e.id.startsWith('earth_fill') ||
        e.id.startsWith('retaining_edge') ||
        e.id.startsWith('plinth_beam')) {
      e.opacity = 0.55;
    } else {
      e.opacity = 0.16;
    }
  }

  void _applyBlockAssemblyViewFilters(BimEntity e) {
    if (!isAdvancedInterlocking) {
      e.opacity = 1;
      return;
    }
    if (e.id.startsWith('blk_') ||
        e.id == 'block_lock_demo' ||
        e.componentId == 'interlocking_block') {
      e.opacity = 1;
    } else if (e.id.startsWith('grout')) {
      e.opacity = 0.45;
    } else {
      e.opacity = 0.14;
    }
  }

  /// 0 = assembled wall, 1 = exploded blocks (block assembly mode).
  double get blockDisassembleFactor =>
      (math.sin(blockAssemblyPhase * 0.32) + 1) / 2;

  void _applyAdvancedInterlockingEarthquakeViewFilters(BimEntity e) {
    if (!isAdvancedInterlocking) {
      e.opacity = 1;
      return;
    }
    if (e.id == 'conventional_masonry_ghost' ||
        e.id == 'wall_separation_hint') {
      e.opacity = 1;
      return;
    }
    if (e.id.startsWith('grout') || e.category == BimEntityCategory.rebar) {
      e.opacity = 1;
    } else if (e.id.contains('band') ||
        e.id.startsWith('blk_') ||
        e.category == BimEntityCategory.masonry) {
      e.opacity = 0.92;
    } else {
      e.opacity = 0.22;
    }
  }

  void _applyModularAssemblyViewFilters(BimEntity e) {
    if (!isPrefabricated) {
      e.opacity = 1;
      return;
    }
    if (e.id == 'mobile_crane' || e.id == 'crane_boom') {
      final t = modularDisassembleFactor;
      e.opacity = t > 0.25 && t < 0.88 ? 1 : 0.4;
      return;
    }
    if (e.explodeGroup >= 2 && e.explodeGroup <= 4) {
      e.opacity = 1;
    } else if (e.id == 'factory_module_note') {
      e.opacity = 1;
    } else {
      e.opacity = 0.18;
    }
  }

  /// 0 = assembled, 1 = fully disassembled (modular assembly mode).
  double get modularDisassembleFactor =>
      (math.sin(modularPhase * 0.35) + 1) / 2;

  void _applyBuoyancyViewFilters(BimEntity e) {
    if (!isAmphibious) {
      e.opacity = 1;
      return;
    }
    if (e.id.startsWith('buoy_drum') ||
        e.componentId == 'buoyant_drum' ||
        e.id == 'floating_deck' ||
        e.id == 'platform_frame') {
      e.opacity = 1;
    } else if (e.id == 'flood_water') {
      e.opacity = 0.55;
      e.buildProgress = 0.9;
    } else if (e.explodeGroup == 5) {
      e.opacity = 0.45;
    } else if (e.explodeGroup <= 2) {
      e.opacity = 0.2;
    } else {
      e.opacity = 0.12;
    }
  }

  BimVec3 explodeOffset(BimEntity e) {
    if (viewMode == BimVisualizationMode.cavityWall && isRatTrapBond) {
      if (e.id.contains('_brick')) return const BimVec3(0, 0, 0.18);
      if (e.id.contains('_cavity')) return const BimVec3(0, 0, -0.06);
    }
    if (viewMode == BimVisualizationMode.modularAssembly && isPrefabricated) {
      final t = modularDisassembleFactor;
      final g = e.explodeGroup;
      if (g == 0) return BimVec3.zero;
      final sign = g.isOdd ? 1.0 : -1.0;
      return BimVec3(
        (g - 2) * 0.9 * t * sign,
        g * 0.55 * t,
        (g - 1) * 0.7 * t,
      );
    }
    if (viewMode == BimVisualizationMode.blockAssembly && isAdvancedInterlocking) {
      final t = blockDisassembleFactor;
      if (e.id.startsWith('blk_')) {
        final idx = int.tryParse(e.id.split('_').last) ?? 0;
        final angle = idx * 0.37;
        return BimVec3(
          math.cos(angle) * 0.35 * t,
          (idx % 7) * 0.08 * t,
          math.sin(angle) * 0.28 * t,
        );
      }
      if (e.id == 'block_lock_demo') {
        return BimVec3(0.5 * t, 0.2 * t, 0);
      }
    }
    if (viewMode == BimVisualizationMode.connection && isLightGaugeSteel) {
      if (e.category == BimEntityCategory.equipment ||
          e.id.contains('anchor') ||
          e.id.contains('screw') ||
          e.id.contains('gusset')) {
        return BimVec3(0.25, 0.15, 0.1);
      }
      return BimVec3.zero;
    }
    if (viewMode != BimVisualizationMode.exploded) return BimVec3.zero;
    final g = e.explodeGroup;
    if (g == 0) return BimVec3.zero;
    final c = e.bounds.center + e.position;
    final dx = c.x - _sceneCenter.x;
    final dy = c.y - _sceneCenter.y;
    final dz = c.z - _sceneCenter.z;
    final len = math.sqrt(dx * dx + dy * dy + dz * dz);
    if (len < 0.05) {
      return BimVec3(0, g * 0.12, g * 0.08);
    }
    final scale = (g * 0.28) / len;
    return BimVec3(dx * scale, dy * scale, dz * scale);
  }

  /// Vertical lift of floating assembly during flood simulation (meters).
  double get amphibiousFloatLift {
    if (!isAmphibious || viewMode != BimVisualizationMode.flood) return 0;
    final t = (math.sin(floodPhase * 0.35 - math.pi / 2) + 1) / 2;
    return t * AmphibiousDimensions.maxFloatRise;
  }

  BimVec3 floatOffset(BimEntity e) {
    final lift = amphibiousFloatLift;
    if (lift > 0 && e.explodeGroup == 5) return BimVec3(0, lift, 0);
    final slide = landslideSlideOffset;
    if (slide > 0 && e.id == 'unreinforced_slope_mass') {
      return BimVec3(-slide * 0.4, -slide, slide * 0.2);
    }
    if (isLohKaat &&
        viewMode == BimVisualizationMode.earthquake &&
        e.id == 'no_band_wall_ghost') {
      final crack = (math.sin(earthquakePhase * 2) + 1) / 2;
      return BimVec3(crack * 0.25, -crack * 0.15, 0);
    }
    if (isReinforcedAdobe &&
        (viewMode == BimVisualizationMode.earthquake ||
            viewMode == BimVisualizationMode.seismic) &&
        e.id == 'traditional_adobe_ghost') {
      final t = (math.sin(earthquakePhase * 1.8) + 1) / 2;
      return BimVec3(t * 0.4, -t * 0.5, t * 0.08);
    }
    if (isTimberFrameLath &&
        (viewMode == BimVisualizationMode.earthquake ||
            viewMode == BimVisualizationMode.seismic)) {
      final sway = (math.sin(earthquakePhase * 2.2) + 1) / 2;
      if (e.id == 'unbraced_frame_ghost') {
        return BimVec3(sway * 0.5, -sway * 0.65, sway * 0.12);
      }
      if (e.category == BimEntityCategory.timber && !e.id.contains('ghost')) {
        return BimVec3(sway * 0.06, 0, sway * 0.04);
      }
    }
    if (isAdvancedInterlocking &&
        (viewMode == BimVisualizationMode.earthquake ||
            viewMode == BimVisualizationMode.seismic)) {
      final shake = (math.sin(earthquakePhase * 2) + 1) / 2;
      if (e.id == 'conventional_masonry_ghost') {
        return BimVec3(shake * 0.45, -shake * 0.55, shake * 0.1);
      }
      if (e.id == 'wall_separation_hint') {
        return BimVec3(shake * 0.2, 0, 0);
      }
      if (e.id.startsWith('blk_') || e.id.contains('band')) {
        return BimVec3(shake * 0.03, 0, shake * 0.02);
      }
    }
    final craneLift = _prefabCraneLift(e);
    if (craneLift > 0) return BimVec3(0, craneLift, 0);
    return BimVec3.zero;
  }

  double _prefabCraneLift(BimEntity e) {
    if (!isPrefabricated) return 0;
    if (viewMode == BimVisualizationMode.modularAssembly) {
      final t = modularDisassembleFactor;
      if (e.id.startsWith('floor_panel') ||
          e.id.startsWith('wall_') ||
          e.id.startsWith('roof_panel')) {
        return t * 1.8;
      }
      return 0;
    }
    if (!isPlaying) return 0;
    final si = stageIndex;
    final p = stageProgress;
    if (si == 5 && e.id.startsWith('floor_panel')) {
      return (1 - p.clamp(0, 1)) * 1.2;
    }
    if (si == 6 && e.id.startsWith('wall_') && e.id.contains('skin_ext')) {
      return (1 - p.clamp(0, 1)) * 1.5;
    }
    if (si == 9 && e.id.startsWith('roof_panel')) {
      return (1 - p.clamp(0, 1)) * 1.4;
    }
    return 0;
  }

  /// Unreinforced slope slide distance during landslide demo (meters).
  double get landslideSlideOffset {
    if (!isGeogrid || viewMode != BimVisualizationMode.landslide) return 0;
    final t = (math.sin(landslidePhase * 0.4) + 1) / 2;
    if (t < 0.42) return t / 0.42 * 1.8;
    if (t < 0.55) return 1.8;
    return 1.8 * (1 - (t - 0.55) / 0.45);
  }

  bool passesCrossSection(BimVec3 world) {
    if (!crossSectionEnabled) return true;
    return world.x <= _package.crossSectionCenterX + 0.15;
  }

  bool get isEarthbag => modelId == 'earthbag_masonry';

  bool get isCementBamboo => modelId == 'cement_bamboo_frame';

  bool get isConfinedBlock => modelId == 'confined_concrete_block_masonry';

  bool get isElevatedFlood => modelId == 'elevated_flood_resilient_house';

  bool get isAmphibious => modelId == 'floating_amphibious_structure';

  bool get isFlyAsh => modelId == 'fly_ash_masonry';

  bool get isGeogrid => modelId == 'geogrid_reinforced_retaining_wall';

  bool get isLightGaugeSteel => modelId == 'light_gauge_steel_house';

  bool get isLohKaat => modelId == 'loh_kaat_timber_house';

  bool get isPrefabricated => modelId == 'pre_fabricated_house';

  bool get isRaisedPlinth => modelId == 'raised_plinth_flood_resilient_house';

  bool get isRatTrapBond => modelId == 'rat_trap_bond_masonry';

  bool get isReinforcedAdobe => modelId == 'reinforced_adobe_brick_structure';

  bool get isTimberFrameLath => modelId == 'timber_frame_lath_plaster';

  bool get isAdvancedInterlocking =>
      modelId == 'advanced_interlocking_brick_masonry';
}
