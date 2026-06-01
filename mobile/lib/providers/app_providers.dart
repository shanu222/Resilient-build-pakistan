import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/hazard_profile.dart';
import '../data/models/house_model.dart';
import '../data/models/resilience_dimensions.dart';
import '../data/repositories/firebase_admin_repository.dart';
import '../data/repositories/json_asset_repository.dart';
import '../data/repositories/local_storage_repository.dart';
import '../domain/services/location_intelligence_engine.dart';
import '../domain/services/hazard_recommendation_engine.dart';
import '../domain/services/model_recommendation_engine.dart';
import '../features/inspection/ai_inspection_service.dart';

final jsonRepoProvider = Provider<JsonAssetRepository>((ref) {
  return JsonAssetRepository();
});

final localStorageProvider = Provider<LocalStorageRepository>((ref) {
  return LocalStorageRepository();
});

final locationEngineProvider = Provider<LocationIntelligenceEngine>((ref) {
  return LocationIntelligenceEngine();
});

final recommendationEngineProvider =
    Provider<ModelRecommendationEngine>((ref) {
  return ModelRecommendationEngine();
});

final hazardRecommendationEngineProvider =
    Provider<HazardRecommendationEngine>((ref) {
  return HazardRecommendationEngine(
    locationEngine: ref.watch(locationEngineProvider),
    modelEngine: ref.watch(recommendationEngineProvider),
  );
});

final firebaseAdminProvider = Provider<FirebaseAdminRepository>((ref) {
  return FirebaseAdminRepository();
});

final aiInspectionProvider = Provider<AiInspectionService>((ref) {
  return AiInspectionService();
});

final housesProvider = FutureProvider<List<HouseModel>>((ref) async {
  return ref.watch(jsonRepoProvider).getHouses();
});

final houseByIdProvider =
    FutureProvider.family<HouseModel?, String>((ref, id) async {
  return ref.watch(jsonRepoProvider).getHouseById(id);
});

final resilienceScoresProvider =
    FutureProvider.family<ResilienceDimensions, String>((ref, modelId) async {
  return ref.watch(jsonRepoProvider).getResilienceScores(modelId);
});

class LocationState {
  const LocationState({
    this.latitude = 31.5204,
    this.longitude = 74.3587,
    this.placeName,
    this.profile,
    this.isLoading = false,
  });

  final double latitude;
  final double longitude;
  final String? placeName;
  final HazardProfile? profile;
  final bool isLoading;

  LocationState copyWith({
    double? latitude,
    double? longitude,
    String? placeName,
    HazardProfile? profile,
    bool? isLoading,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeName: placeName ?? this.placeName,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier(this._ref) : super(const LocationState());

  final Ref _ref;

  Future<void> analyzeAt(double lat, double lng, {String? placeName}) async {
    state = state.copyWith(isLoading: true, latitude: lat, longitude: lng);
    final engine = _ref.read(locationEngineProvider);
    final profile = engine.analyze(
      latitude: lat,
      longitude: lng,
      placeName: placeName,
    );
    state = state.copyWith(
      profile: profile,
      placeName: placeName ?? profile.displayName,
      isLoading: false,
    );
    await _ref.read(localStorageProvider).saveLocation({
      'id': '${lat}_$lng',
      'lat': lat,
      'lng': lng,
      'name': profile.displayName,
      'regionId': profile.regionId,
      'at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> analyzeCurrent() => analyzeAt(state.latitude, state.longitude);
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref);
});

final recommendedModelsProvider = FutureProvider<List<HouseModel>>((ref) async {
  final location = ref.watch(locationProvider);
  final profile = location.profile;
  final repo = ref.watch(jsonRepoProvider);
  final houses = await repo.getHouses();
  if (profile == null) return houses;
  final regionRecs = await repo.getRegionRecommendations();
  final engine = ref.watch(recommendationEngineProvider);
  return engine.recommend(
    profile: profile,
    allModels: houses,
    regionRecommendations: regionRecs,
  );
});

final selectedModelIdProvider = StateProvider<String?>((ref) => null);

class ConstructionSimulationState {
  const ConstructionSimulationState({
    this.currentStageIndex = 0,
    this.isPlaying = false,
    this.playbackSpeed = 1.0,
    this.viewMode = SimulationViewMode.structural,
    this.explodedView = false,
    this.crossSection = false,
  });

  final int currentStageIndex;
  final bool isPlaying;
  final double playbackSpeed;
  final SimulationViewMode viewMode;
  final bool explodedView;
  final bool crossSection;

  ConstructionSimulationState copyWith({
    int? currentStageIndex,
    bool? isPlaying,
    double? playbackSpeed,
    SimulationViewMode? viewMode,
    bool? explodedView,
    bool? crossSection,
  }) {
    return ConstructionSimulationState(
      currentStageIndex: currentStageIndex ?? this.currentStageIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      viewMode: viewMode ?? this.viewMode,
      explodedView: explodedView ?? this.explodedView,
      crossSection: crossSection ?? this.crossSection,
    );
  }
}

enum SimulationViewMode { structural, materials, normal }

class ConstructionSimulationNotifier
    extends StateNotifier<ConstructionSimulationState> {
  ConstructionSimulationNotifier() : super(const ConstructionSimulationState());

  void setStage(int index) => state = state.copyWith(currentStageIndex: index);
  void togglePlay() => state = state.copyWith(isPlaying: !state.isPlaying);
  void setSpeed(double s) => state = state.copyWith(playbackSpeed: s);
  void setViewMode(SimulationViewMode m) => state = state.copyWith(viewMode: m);
  void toggleExploded() =>
      state = state.copyWith(explodedView: !state.explodedView);
  void toggleCrossSection() =>
      state = state.copyWith(crossSection: !state.crossSection);
  void reset() => state = const ConstructionSimulationState();
}

final constructionSimulationProvider = StateNotifierProvider<
    ConstructionSimulationNotifier, ConstructionSimulationState>((ref) {
  return ConstructionSimulationNotifier();
});
