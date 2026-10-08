import '../models/dpp_session_video.dart';

/// SINGLE SOURCE OF TRUTH for every DPP session video.
///
/// Contains ALL 16 core DPP sessions (`session_01` through `session_16`,
/// orders 1 through 16).
///
/// When the official HEALIS YouTube channel is ready, this is the ONLY
/// file that needs to change. For each session:
///
///   1. Replace the `videoId` placeholder (e.g. 'PLACEHOLDER_SESSION_01')
///      with the real YouTube video ID from the unlisted upload.
///   2. Set `isAvailable: true`.
///
/// Nothing else in the app needs to change — the player, the screen, and
/// the progress service all key off this list.
const List<DppSessionVideo> dppSessionVideos = [
  DppSessionVideo(
    sessionId: 'session_01',
    title: 'Welcome to Your Diabetes Prevention Journey',
    videoId: '47GaQD-_zdA',
    description:
        'Introduction to the DPP program and how small changes reduce your risk of type 2 diabetes.',
    order: 1,
    isAvailable: true,
  ),
  DppSessionVideo(
    sessionId: 'session_02',
    title: 'Become a Fat & Calorie Detective',
    videoId: '4Bit209Xcmc',
    description:
        'Learn how calories and fat impact weight loss and blood sugar management.',
    order: 2,
    isAvailable: true,
  ),
  DppSessionVideo(
    sessionId: 'session_03',
    title: 'Three Ways to Eat Less Fat and Fewer Calories',
    videoId: 'PLACEHOLDER_SESSION_03',
    description:
        'Practical strategies to swap ingredients and make healthier meal choices.',
    order: 3,
    isAvailable: false,
  ),
  DppSessionVideo(
    sessionId: 'session_04',
    title: 'Healthy Eating on the Go',
    videoId: 'PLACEHOLDER_SESSION_04',
    description:
        'Navigating quick meals, portion sizes, and snacks when eating away from home.',
    order: 4,
    isAvailable: false,
  ),
  DppSessionVideo(
    sessionId: 'session_05',
    title: 'Move Your Body & Build Momentum',
    videoId: 'PLACEHOLDER_SESSION_05',
    description:
        'Why movement matters and how to gradually increase active minutes safely.',
    order: 5,
    isAvailable: false,
  ),
  DppSessionVideo(
    sessionId: 'session_06',
    title: 'Being Active as a Way of Life',
    videoId: 'PLACEHOLDER_SESSION_06',
    description:
        'Making physical activity a regular, enjoyable habit in your daily routine.',
    order: 6,
    isAvailable: false,
  ),
  DppSessionVideo(
    sessionId: 'session_07',
    title: 'Track Your Eating & Activity',
    videoId: 'PLACEHOLDER_SESSION_07',
    description:
        'Using logs and self-monitoring tools to build awareness and stay consistent.',
    order: 7,
    isAvailable: false,
  ),
  DppSessionVideo(
    sessionId: 'session_08',
    title: 'Take Charge of What\'s Around You',
    videoId: 'PLACEHOLDER_SESSION_08',
    description:
        'Managing your environment, cues, and food triggers for long-term success.',
    order: 8,
    isAvailable: false,
  ),
  DppSessionVideo(
    sessionId: 'session_09',
    title: 'Problem Solving & Overcoming Barriers',
    videoId: 'PLACEHOLDER_SESSION_09',
    description:
        'A 5-step problem solving method to navigate unexpected lifestyle challenges.',
    order: 9,
    isAvailable: false,
  ),
  DppSessionVideo(
    sessionId: 'session_10',
    title: 'Four Keys to Healthy Eating Out',
    videoId: 'PLACEHOLDER_SESSION_10',
    description:
        'Smart strategies for restaurants, social gatherings, and celebrations.',
    order: 10,
    isAvailable: false,
  ),
  DppSessionVideo(
    sessionId: 'session_11',
    title: 'Talk Back to Negative Thoughts',
    videoId: 'PLACEHOLDER_SESSION_11',
    description:
        'Reframing self-talk and building a positive mindset for sustainable health.',
    order: 11,
    isAvailable: false,
  ),
  DppSessionVideo(
    sessionId: 'session_12',
    title: 'Slip Up & Recovery Strategies',
    videoId: 'PLACEHOLDER_SESSION_12',
    description:
        'How to recover quickly from slips and avoid letting small setbacks stop progress.',
    order: 12,
    isAvailable: false,
  ),
  DppSessionVideo(
    sessionId: 'session_13',
    title: 'Manage Stress & Restore Balance',
    videoId: 'PLACEHOLDER_SESSION_13',
    description:
        'Understanding the stress-eating connection and techniques to relax and recharge.',
    order: 13,
    isAvailable: false,
  ),
  DppSessionVideo(
    sessionId: 'session_14',
    title: 'Stay Motivated & Keep Going',
    videoId: 'PLACEHOLDER_SESSION_14',
    description:
        'Revisiting your core goals, celebrating progress, and staying inspired.',
    order: 14,
    isAvailable: false,
  ),
  DppSessionVideo(
    sessionId: 'session_15',
    title: 'Heart Health & Active Lifestyle',
    videoId: 'PLACEHOLDER_SESSION_15',
    description:
        'Protecting your heart, blood vessels, and metabolic health for life.',
    order: 15,
    isAvailable: false,
  ),
  DppSessionVideo(
    sessionId: 'session_16',
    title: 'Looking Back and Moving Forward',
    videoId: 'PLACEHOLDER_SESSION_16',
    description:
        'Reviewing achievements from the 16 core weeks and planning long-term maintenance.',
    order: 16,
    isAvailable: false,
  ),
];

/// Singleton class helper or functional API for accessing session video data.
class DppSessionVideos {
  static List<DppSessionVideo> get all => dppSessionVideos;

  /// Looks up a session video by its [sessionId].
  /// Returns null if no matching session exists.
  static DppSessionVideo? lookup(String sessionId) {
    for (final video in dppSessionVideos) {
      if (video.sessionId == sessionId) return video;
    }
    return null;
  }

  /// Gets a session video by 1-based [order] (1..16).
  static DppSessionVideo? getByOrder(int order) {
    for (final video in dppSessionVideos) {
      if (video.order == order) return video;
    }
    return null;
  }
}

/// Standalone helper function for backward compatibility.
DppSessionVideo? findDppSessionVideo(String sessionId) =>
    DppSessionVideos.lookup(sessionId);

/// Returns all configured sessions sorted by [DppSessionVideo.order].
List<DppSessionVideo> get orderedDppSessionVideos {
  final list = List<DppSessionVideo>.from(dppSessionVideos);
  list.sort((a, b) => a.order.compareTo(b.order));
  return list;
}
