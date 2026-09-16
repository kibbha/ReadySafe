class Guide {
  const Guide({
    required this.id,
    required this.title,
    required this.icon,
    required this.immediate,
    required this.avoid,
    required this.steps,
    required this.callHelp,
    required this.evacuate,
  });
  final String id, title, immediate, avoid, callHelp, evacuate;
  final String icon;
  final List<String> steps;
}
