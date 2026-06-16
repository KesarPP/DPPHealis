class HandoutItem {
  final int number;
  final String title;
  const HandoutItem(this.number, this.title);
}

class SessionHandout {
  final String sessionName;
  final List<HandoutItem> items;
  const SessionHandout(this.sessionName, this.items);
}

class ModuleHandout {
  final int moduleNumber;
  final String moduleName;
  final List<SessionHandout> sessions;
  const ModuleHandout(this.moduleNumber, this.moduleName, this.sessions);
}

const List<ModuleHandout> foodHandouts = [
  ModuleHandout(1, 'Understanding Prediabetes & Nutrition Foundations', [
    SessionHandout('Session 1: Welcome to Your Diabetes Prevention Journey', [
      HandoutItem(1, 'Understanding Prediabetes'),
      HandoutItem(2, 'Understanding Type 2 Diabetes'),
      HandoutItem(3, 'Introduction to NDPP'),
      HandoutItem(4, 'Why Manage Weight?'),
    ]),
    SessionHandout('Session 2: Become a Fat & Calorie Detective', [
      HandoutItem(1, 'Understanding Calories'),
      HandoutItem(2, 'Understanding Fat'),
      HandoutItem(3, 'Fat in Foods'),
      HandoutItem(4, 'Hidden Calories and Hidden Fats'),
      HandoutItem(5, 'Why Hidden Calories Matter'),
    ]),
    SessionHandout('Session 3: Reducing Fat & Calories', [
      HandoutItem(1, 'Reducing Fat Intake: Measuring and Preparation'),
      HandoutItem(2, 'Everyday Fat Reduction Strategies'),
      HandoutItem(3, 'Reducing Calories Without Feeling Deprived'),
    ]),
    SessionHandout('Session 4: Healthy Eating for Life', [
      HandoutItem(1, 'Principles of Healthy Eating'),
      HandoutItem(2, 'Healthy Eating with Variety & Balance'),
      HandoutItem(3, 'More Volume, Fewer Calories'),
      HandoutItem(4, 'Starchy Foods and Fiber'),
      HandoutItem(5, 'Healthy Food Preparation'),
      HandoutItem(6, 'Mindful Eating'),
    ]),
  ]),
];
const List<ModuleHandout> activityHandouts = [
  ModuleHandout(2, 'Physical Activity & Weight Loss', [
    SessionHandout('Session 5: Move Those Muscles', [
      HandoutItem(1, 'Understanding Physical Activity'),
      HandoutItem(2, 'Why Physical Activity Matters'),
      HandoutItem(3, 'Health Benefits of Physical Activity'),
      HandoutItem(4, 'Physical Activity and Insulin Resistance'),
      HandoutItem(5, 'Understanding Activity Intensity'),
      HandoutItem(6, 'The NDPP Physical Activity Goal'),
      HandoutItem(7, 'Identifying Opportunities to Move More'),
      HandoutItem(8, 'Building an Active Mindset'),
    ]),
    SessionHandout('Session 6: Being Active as a Way of Life', [
      HandoutItem(1, 'Making Physical Activity a Lifestyle'),
      HandoutItem(2, 'Getting Started Safely'),
      HandoutItem(3, 'Types of Physical Activity'),
      HandoutItem(4, 'Finding Activities You Enjoy'),
      HandoutItem(5, 'Reducing Sedentary Time'),
      HandoutItem(6, 'Creating an Activity Plan'),
      HandoutItem(7, 'Choosing Activities'),
    ]),
    SessionHandout('Session 7: Tip the Calorie Balance', [
      HandoutItem(1, 'Understanding Calorie Balance'),
      HandoutItem(2, 'Where Calories Go'),
      HandoutItem(3, 'Understanding Weight Change'),
      HandoutItem(4, 'Food and Activity Work Together'),
      HandoutItem(5, 'Setting Realistic Expectations'),
      HandoutItem(6, 'Understanding Weight Loss Plateaus'),
      HandoutItem(7, 'Tracking Progress'),
      HandoutItem(8, 'Long-Term Weight Management'),
    ]),
  ]),
];

const List<ModuleHandout> psychologyHandouts = [
  ModuleHandout(3, 'Psychology & Behavior Change', [
    SessionHandout('Session 8: Take Charge of What\'s Around You', [
      HandoutItem(1, 'Understanding Behaviour Triggers'),
      HandoutItem(2, 'Understanding Personal Triggers'),
      HandoutItem(3, 'Creating a Healthy Environment'),
    ]),
    SessionHandout('Session 9: Problem Solving', [
      HandoutItem(1, 'Understanding Problems and Barriers'),
      HandoutItem(2, 'Understanding Problem Solving'),
      HandoutItem(3, 'Dealing with Setback'),
      HandoutItem(4, 'Strategies for Future Situations'),
      HandoutItem(5, 'Building a Problem-Solving Mindset'),
    ]),
    SessionHandout('Session 10: Four Keys to Healthy Eating Out', [
      HandoutItem(1, 'Understanding Challenges of Eating Outside the Home'),
      HandoutItem(2, 'Key 1: Plan Ahead'),
      HandoutItem(3, 'Key 2: Make Healthy Choices'),
      HandoutItem(4, 'Key 3: Watch Portion Sizes'),
      HandoutItem(5, 'Key 4: Eat Mindfully'),
    ]),
    SessionHandout('Session 11: Talk Back to Negative Thoughts', [
      HandoutItem(1, 'Identifying Negative Thoughts'),
      HandoutItem(2, 'Understanding Self-Defeating Thinking'),
      HandoutItem(3, 'Challenging Negative Thoughts'),
      HandoutItem(4, 'Replacing Negative Thoughts'),
      HandoutItem(5, 'Building Self-Confidence'),
    ]),
    SessionHandout('Session 12: The Slippery Slope of Lifestyle Change', [
      HandoutItem(1, 'Understanding Lifestyle Change'),
      HandoutItem(2, 'Understanding Lapses'),
      HandoutItem(3, 'Understanding the Slippery Slope'),
      HandoutItem(4, 'Lapse vs Relapse'),
      HandoutItem(5, 'Responding to a Lapse'),
      HandoutItem(6, 'Recognize What Happened'),
      HandoutItem(7, 'Building Long-Term Success'),
    ]),
  ]),
];

const List<ModuleHandout> maintenanceHandouts = [
  ModuleHandout(4, 'Long-Term Maintenance', [
    SessionHandout('Session 13: Jump Start Your Activity Plan', [
      HandoutItem(1, 'The Importance of Staying Active'),
      HandoutItem(2, 'Reviewing Your Current Activity'),
      HandoutItem(3, 'Building an Activity Plan'),
      HandoutItem(4, 'Increasing Activity Levels Safely'),
      HandoutItem(5, 'Making Activity a Habit'),
      HandoutItem(6, 'Staying Motivated'),
    ]),
    SessionHandout('Session 14: Make Social Cues Work for You', [
      HandoutItem(1, 'Understanding Social Cues'),
      HandoutItem(2, 'Positive and Negative Social Influences'),
      HandoutItem(3, 'Identifying Your Support Network'),
      HandoutItem(4, 'Communicating Your Goals'),
      HandoutItem(5, 'Building a Supportive Environment'),
      HandoutItem(6, 'Using Social Support During Challenges'),
      HandoutItem(7, 'Long-Term Success Through Social Support'),
    ]),
    SessionHandout('Session 15: You Can Manage Stress', [
      HandoutItem(1, 'Understanding Stress'),
      HandoutItem(2, 'How Stress Affects Lifestyle Habits'),
      HandoutItem(3, 'Healthy Stress Management Strategies'),
      HandoutItem(4, 'Understanding Time Management'),
      HandoutItem(5, 'Improving Time Management'),
      HandoutItem(6, 'Managing Stress During Lifestyle Change'),
    ]),
    SessionHandout('Session 16: Ways to Stay Motivated', [
      HandoutItem(1, 'Understanding Motivation'),
      HandoutItem(2, 'Staying Motivated for the Long Term'),
      HandoutItem(3, 'Balance Your Thoughts for Long-Term Maintenance'),
      HandoutItem(4, 'Handling Holidays, Vacations, and Special Events'),
      HandoutItem(5, 'Understanding Relapse Prevention'),
      HandoutItem(6, 'Preventing Relapse'),
      HandoutItem(7, 'Looking Ahead'),
    ]),
  ]),
];

const List<ModuleHandout> graduationHandouts = [
  ModuleHandout(5, 'Graduation & Lifelong Health', [
    SessionHandout('Module 5: Graduation & Lifelong Health', [
      HandoutItem(1, 'Looking Back on Your Journey'),
      HandoutItem(2, 'The Power of Small Changes'),
      HandoutItem(3, 'Looking Forward'),
      HandoutItem(4, 'Your Commitment to the Future'),
    ]),
  ]),
];

// NDPP gets both modules combined
const List<ModuleHandout> ndppHandouts = [
  ...foodHandouts,
  ...activityHandouts,
  ...psychologyHandouts,
  ...maintenanceHandouts,
  ...graduationHandouts,
];