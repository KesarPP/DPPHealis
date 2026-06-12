enum ModuleState { locked, current, pendingQuiz, completed }
enum SessionState { locked, current, completed }

class SessionNode {
  final int number;
  final String title;
  final SessionState state;
  const SessionNode(this.number, this.title, this.state);
}

class ModuleNode {
  final int number;
  final String title;
  final ModuleState state;
  final List<SessionNode> sessions;
  const ModuleNode(this.number, this.title, this.state, this.sessions);
}

const List<ModuleNode> journeyModules = [
  ModuleNode(1, 'Understanding\nPrediabetes & Nutrition\nFoundations', ModuleState.completed, []),
  ModuleNode(2, 'Physical Activity\n& Weight Loss', ModuleState.completed, []),
  ModuleNode(3, 'Blood Sugar\nMonitoring\n& Management', ModuleState.completed, []),
  ModuleNode(4, 'Healthy Eating\n& Meal Planning', ModuleState.completed, []),
  ModuleNode(5, 'Stress Management\n& Better Sleep', ModuleState.completed, []),
  ModuleNode(6, 'Long-term Habits\n& Staying on Track', ModuleState.locked, []),
];