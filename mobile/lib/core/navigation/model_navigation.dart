import '../../data/models/house_model.dart';

/// Ordered model navigation for prev/next controls.
class ModelNavigation {
  static ({HouseModel? prev, HouseModel? next}) neighbors(
    List<HouseModel> models,
    String currentId,
  ) {
    final i = models.indexWhere((m) => m.id == currentId);
    if (i < 0) return (prev: null, next: null);
    return (
      prev: i > 0 ? models[i - 1] : null,
      next: i < models.length - 1 ? models[i + 1] : null,
    );
  }
}
