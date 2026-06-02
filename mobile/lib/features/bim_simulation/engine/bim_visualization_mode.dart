enum BimVisualizationMode {
  normal('Normal View'),
  exploded('Exploded View'),
  structural('Structural View'),
  rebar('Rebar View'),
  loadTransfer('Load Transfer View'),
  earthquake('Earthquake Simulation'),
  seismic('Seismic Behavior'),
  drainage('Drainage View'),
  flood('Flood Simulation'),
  buoyancy('Buoyancy View'),
  hydraulic('Hydraulic View'),
  bambooFrame('Bamboo Frame View'),
  steelFrame('Steel Frame View'),
  connection('Connection View'),
  timberBand('Timber Band View'),
  thermal('Thermal Performance View'),
  modularAssembly('Modular Assembly View'),
  blockAssembly('Block Assembly View'),
  cavityWall('Cavity Wall View'),
  materialComparison('Material Comparison'),
  reinforcement('Reinforcement View'),
  timberSkeleton('Timber Skeleton View'),
  earthPressure('Earth Pressure View'),
  landslide('Landslide Simulation'),
  wind('Wind Simulation'),
  foundation('Foundation View'),
  groundwater('Groundwater View'),
  sequence('Construction Sequence');

  const BimVisualizationMode(this.label);
  final String label;
}
