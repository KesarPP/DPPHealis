enum ModuleState { locked, current, completed }
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
  ModuleNode(1, 'Understanding Prediabetes\n& Nutrition Foundations', ModuleState.completed, [
    SessionNode(1, 'Welcome to Your\nDPP Journey', SessionState.completed),
    SessionNode(2, 'Become a Fat &\nCalorie Detective', SessionState.completed),
    SessionNode(3, 'Reducing Fat\n& Calories', SessionState.completed),
    SessionNode(4, 'Healthy Eating\nfor Life', SessionState.completed),
  ]),
  ModuleNode(2, 'Physical Activity\n& Weight Loss', ModuleState.current, [
    SessionNode(5, 'Move Those\nMuscles', SessionState.completed),
    SessionNode(6, 'Being Active as\na Way of Life', SessionState.current),
    SessionNode(7, 'Tip the Calorie\nBalance', SessionState.locked),
  ]),
  ModuleNode(3, 'Psychology &\nBehavior Change', ModuleState.locked, [
    SessionNode(8, 'Take Charge of\nWhat\'s Around You', SessionState.locked),
    SessionNode(9, 'Problem Solving', SessionState.locked),
    SessionNode(10, 'Four Keys to\nHealthy Eating Out', SessionState.locked),
    SessionNode(11, 'Talk Back to\nNegative Thoughts', SessionState.locked),
    SessionNode(12, 'The Slippery Slope\nof Lifestyle Change', SessionState.locked),
  ]),
  ModuleNode(4, 'Long-Term\nMaintenance', ModuleState.locked, [
    SessionNode(13, 'Jump Start Your\nActivity Plan', SessionState.locked),
    SessionNode(14, 'Make Social Cues\nWork for You', SessionState.locked),
    SessionNode(15, 'You Can\nManage Stress', SessionState.locked),
    SessionNode(16, 'Ways to Stay\nMotivated', SessionState.locked),
  ]),
  ModuleNode(5, 'Graduation &\nLifelong Health', ModuleState.locked, [
    SessionNode(17, 'Graduation &\nLifelong Health', SessionState.locked),
  ]),
];