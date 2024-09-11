String getEstimatedProductionDuration(String modelName) {
  const Map<String, String> estimatedTimeDict = {
    "TF65": "154 seconds",
    "TF70": "154 seconds",
    "TF85": "160 seconds",
    "TF90": "160 seconds",
    "TF105": "175 seconds",
    "TF110": "175 seconds",
    "TF115": "180 seconds",
    "TF120": "180 seconds",
    "TF150": "185 seconds",
    "TF155": "190 seconds",
    "TF160": "190 seconds",
    "TS190": "295 seconds",
    "TS230": "336 seconds",
    "TF300": "300 seconds"
  };

  final value =
      estimatedTimeDict.entries.firstWhere((entry) => modelName.contains(entry.key), orElse: () => const MapEntry('', 'Value not found')).value;

  if (value != 'Value not found') return value;

  return '2700 seconds';
}
