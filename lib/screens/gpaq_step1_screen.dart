import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
// MainShell
import '../data/gelato_theme.dart';
import 'gpaq_step2_screen.dart';

class GPAQStep1Screen extends StatefulWidget {
  final bool isFromSignup;
  const GPAQStep1Screen({super.key, this.isFromSignup = false});

  @override
  State<GPAQStep1Screen> createState() => _GPAQStep1ScreenState();
}

class _GPAQStep1ScreenState extends State<GPAQStep1Screen> {
  bool _workVigorous = false;
  int _workVigorousDays = 3;
  int _workVigorousHours = 1;
  int _workVigorousMins = 0;
  bool _showVigorousHelp = false;

  bool _workModerate = false;
  int _workModerateDays = 3;
  int _workModerateHours = 1;
  int _workModerateMins = 0;
  bool _showModerateHelp = false;

  // Coach Tour Guide State
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _selectedCoach;
  bool _isLoadingCoach = true;
  bool _showTourGuide = true;
  bool _isPlayingVoice = false;
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _fetchAssignedCoach();
  }

  Future<void> _fetchAssignedCoach() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        final coachId = userDoc.data()?['assignedCoachId'];
        if (coachId != null) {
          final coachDoc = await _firestore.collection('coaches').doc(coachId).get();
          if (coachDoc.exists) {
            setState(() {
              _selectedCoach = coachDoc.data();
              _isLoadingCoach = false;
            });
            _speakIntro();
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching assigned coach: $e');
    }
    setState(() {
      _isLoadingCoach = false;
    });
  }

  int _getCoachAvatarIndex() {
    if (_selectedCoach == null) return 1;
    final localPath = _selectedCoach!['localImagePath'] as String?;
    int? avatarIndex;
    if (localPath != null && localPath.startsWith('avatar_')) {
      avatarIndex = int.tryParse(localPath.replaceFirst('avatar_', ''));
    }
    avatarIndex ??= _selectedCoach!['avatarIndex'] as int?;
    return (avatarIndex ?? 0) + 1; // 1-based index matching new files
  }

  bool _isFemaleCoach() {
    final fileIndex = _getCoachAvatarIndex();
    return fileIndex % 2 == 0;
  }

  Future<void> _speakIntro() async {
    if (_selectedCoach == null) return;
    
    final coachName = _selectedCoach!['name'] ?? 'Coach';
    final isFemale = _isFemaleCoach();
    final text = "Hi! I'm coach $coachName. The next step is to fill the GPAQ assessment which helps us understand your daily physical activity levels across work, travel, and recreation.";

    if (mounted) {
      setState(() {
        _isPlayingVoice = true;
      });
    }

    await _flutterTts.setLanguage("en-US");
    
    try {
      List<dynamic> voices = await _flutterTts.getVoices;
      Map<String, String>? targetVoice;
      
      for (var voice in voices) {
        if (voice is Map) {
          final name = voice['name']?.toString().toLowerCase() ?? '';
          final locale = voice['locale']?.toString() ?? '';
          if (locale.startsWith('en')) {
            if (isFemale && (name.contains('female') || name.contains('zira') || name.contains('samantha') || name.contains('a') || name.contains('c') || name.contains('d') || name.contains('network'))) {
              targetVoice = Map<String, String>.from(voice.cast<String, String>());
              break;
            } else if (!isFemale && (name.contains('male') || name.contains('david') || name.contains('b') || name.contains('e') || name.contains('keynote'))) {
              targetVoice = Map<String, String>.from(voice.cast<String, String>());
              break;
            }
          }
        }
      }
      
      if (targetVoice != null) {
        await _flutterTts.setVoice(targetVoice);
      } else {
        await _flutterTts.setPitch(isFemale ? 1.35 : 0.85);
      }
    } catch (e) {
      await _flutterTts.setPitch(isFemale ? 1.35 : 0.85);
    }

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlayingVoice = false;
        });
      }
    });

    _flutterTts.setErrorHandler((_) {
      if (mounted) {
        setState(() {
          _isPlayingVoice = false;
        });
      }
    });

    await _flutterTts.speak(text);
  }

  Widget _buildTourGuideOverlay() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ),
          ),
          
          // Tour guide content at the bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cloud Thought Bubble
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _selectedCoach?['name'] ?? 'Coach',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'The next step is to fill the GPAQ assessment which helps us understand your daily physical activity levels across work, travel, and recreation.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: GelatoTheme.textDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Mute / Unmute Button
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_isPlayingVoice) {
                                _flutterTts.stop();
                                setState(() {
                                  _isPlayingVoice = false;
                                });
                              } else {
                                _speakIntro();
                              }
                            },
                            icon: Icon(_isPlayingVoice ? Icons.volume_off : Icons.volume_up, size: 18),
                            label: Text(_isPlayingVoice ? 'Mute' : 'Speak'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.black, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                          // Skip Button
                          ElevatedButton.icon(
                            onPressed: () {
                              _flutterTts.stop();
                              setState(() {
                                _showTourGuide = false;
                                _isPlayingVoice = false;
                              });
                            },
                            icon: const Icon(Icons.skip_next, size: 18),
                            label: const Text('Skip'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GelatoTheme.purple,
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.black, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Cloud thought bubble trails pointing to bottom-left
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 60.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2.0),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Coach Portrait at the bottom-left
                Container(
                  height: 250,
                  width: 180,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Image.asset(
                    'assets/images/coaches/coach_${_getCoachAvatarIndex()}.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomLeft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isFromSignup,
      child: Scaffold(
        backgroundColor: GelatoTheme.bg,
        appBar: AppBar(
          automaticallyImplyLeading: !widget.isFromSignup,
          backgroundColor: GelatoTheme.bg,
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.directions_run_outlined,
              color: GelatoTheme.purpleDark,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'GPAQ Assessment',
              style: TextStyle(
                color: GelatoTheme.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            IgnorePointer(
              ignoring: _showTourGuide,
              child: Column(
                children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stepper Row
                    const _RiskStepper(activeStep: 4),
                    const SizedBox(height: 16),

                    // Section Indicator Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: GelatoTheme.orange.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 1.0),
                        ),
                        child: const Text(
                          'Activity at Work',
                          style: TextStyle(
                            color: GelatoTheme.orangeDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Screen Title
                    const Center(
                      child: Text(
                        'Risk Assessment (Step 4/7)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card 1: Vigorous Work Activity
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '1. Does your work involve vigorous-intensity activity that causes large increases in breathing or heart rate (e.g. heavy lifting, digging, construction) for at least 10 minutes continuously?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildHelpToggle(
                            isExpanded: _showVigorousHelp,
                            onTap: () => setState(() => _showVigorousHelp = !_showVigorousHelp),
                          ),
                          if (_showVigorousHelp)
                            _buildHelpContent(
                              color: GelatoTheme.yellow,
                              darkColor: GelatoTheme.yellowDark,
                              title: 'Vigorous Work Examples',
                              examples: [
                                'Carrying or lifting heavy loads (>20 kg) like bricks, cement bags, or logs',
                                'Digging, shovelling, or breaking stones',
                                'Heavy construction or physical agricultural work',
                                'Pushing or pulling heavily loaded handcarts',
                              ],
                            ),
                          const SizedBox(height: 12),
                          _buildSegmentedControl2(
                            value: _workVigorous ? 1 : 2,
                            label1: 'Yes',
                            label2: 'No',
                            onChanged: (val) => setState(() => _workVigorous = val == 1),
                            color: GelatoTheme.orange,
                          ),
                          if (_workVigorous) ...[
                            const SizedBox(height: 16),
                            // Nested details card
                            _buildSubCard(
                              color: GelatoTheme.orange,
                              darkColor: GelatoTheme.orangeDark,
                              title: 'VIGOROUS WORK DETAILS',
                              child: Column(
                                children: [
                                  _buildCounterRow(
                                    label: 'Days per week',
                                    value: _workVigorousDays,
                                    onChanged: (val) => setState(() => _workVigorousDays = val),
                                    min: 1,
                                    max: 7,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDurationRow(
                                    label: 'Time per day',
                                    hours: _workVigorousHours,
                                    mins: _workVigorousMins,
                                    onHoursChanged: (val) => setState(() => _workVigorousHours = val),
                                    onMinsChanged: (val) => setState(() => _workVigorousMins = val),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Moderate Work Activity
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '2. Does your work involve moderate-intensity activity that causes small increases in breathing or heart rate (e.g. brisk walking, carrying light loads) for at least 10 minutes continuously?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildHelpToggle(
                            isExpanded: _showModerateHelp,
                            onTap: () => setState(() => _showModerateHelp = !_showModerateHelp),
                          ),
                          if (_showModerateHelp)
                            _buildHelpContent(
                              color: GelatoTheme.yellow,
                              darkColor: GelatoTheme.yellowDark,
                              title: 'Moderate Work Examples',
                              examples: [
                                'Carrying light loads (<10 kg) like boxes, office files, or groceries',
                                'Brisk walking or moving quickly around a workspace',
                                'Sweeping, mopping, scrubbing floors, or window cleaning',
                                'Gardening, light weeding, or harvesting crops',
                              ],
                            ),
                          const SizedBox(height: 12),
                          _buildSegmentedControl2(
                            value: _workModerate ? 1 : 2,
                            label1: 'Yes',
                            label2: 'No',
                            onChanged: (val) => setState(() => _workModerate = val == 1),
                            color: GelatoTheme.orange,
                          ),
                          if (_workModerate) ...[
                            const SizedBox(height: 16),
                            // Nested details card
                            _buildSubCard(
                              color: GelatoTheme.orange,
                              darkColor: GelatoTheme.orangeDark,
                              title: 'MODERATE WORK DETAILS',
                              child: Column(
                                children: [
                                  _buildCounterRow(
                                    label: 'Days per week',
                                    value: _workModerateDays,
                                    onChanged: (val) => setState(() => _workModerateDays = val),
                                    min: 1,
                                    max: 7,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDurationRow(
                                    label: 'Time per day',
                                    hours: _workModerateHours,
                                    mins: _workModerateMins,
                                    onHoursChanged: (val) => setState(() => _workModerateHours = val),
                                    onMinsChanged: (val) => setState(() => _workModerateMins = val),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Bottom Action Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              decoration: const BoxDecoration(
                color: GelatoTheme.bg,
                border: Border(top: BorderSide(color: Colors.black, width: 2.0)),
              ),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, size: 16, color: GelatoTheme.textLight),
                    label: const Text(
                      'Go Back',
                      style: TextStyle(
                        color: GelatoTheme.textLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 0,
                          offset: const Offset(3.5, 3.5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        final vMins = _workVigorous ? (_workVigorousHours * 60 + _workVigorousMins) : 0;
                        final mMins = _workModerate ? (_workModerateHours * 60 + _workModerateMins) : 0;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GPAQStep2Screen(
                              workVigorous: _workVigorous,
                              workVigorousDays: _workVigorous ? _workVigorousDays : 0,
                              workVigorousMinutes: vMins,
                              workModerate: _workModerate,
                              workModerateDays: _workModerate ? _workModerateDays : 0,
                              workModerateMinutes: mMins,
                              isFromSignup: widget.isFromSignup,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GelatoTheme.purple,
                        foregroundColor: GelatoTheme.purpleDark,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black, width: 2.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
        if (_showTourGuide && _selectedCoach != null)
          _buildTourGuideOverlay(),
      ],
    ),
  ),
));
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: child,
    );
  }

  Widget _buildSubCard({
    required Color color,
    required Color darkColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: darkColor,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSegmentedControl2({
    required int value,
    required String label1,
    required String label2,
    required ValueChanged<int> onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              label: label1,
              isSelected: value == 1,
              onTap: () => onChanged(1),
              color: color,
            ),
          ),
          Expanded(
            child: _buildSegmentButton(
              label: label2,
              isSelected: value == 2,
              onTap: () => onChanged(2),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.black, width: 1.5) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? GelatoTheme.textDark : GelatoTheme.textLight,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCounterRow({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    required int min,
    required int max,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: GelatoTheme.textDark,
          ),
        ),
        Row(
          children: [
            _buildCircleButton(
              icon: Icons.remove,
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),
            const SizedBox(width: 12),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: GelatoTheme.textDark,
              ),
            ),
            const SizedBox(width: 12),
            _buildCircleButton(
              icon: Icons.add,
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationRow({
    required String label,
    required int hours,
    required int mins,
    required ValueChanged<int> onHoursChanged,
    required ValueChanged<int> onMinsChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: GelatoTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hours
            Row(
              children: [
                _buildCircleButton(
                  icon: Icons.remove,
                  onPressed: hours > 0 ? () => onHoursChanged(hours - 1) : null,
                ),
                const SizedBox(width: 8),
                Text(
                  '${hours}h',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.textDark,
                  ),
                ),
                const SizedBox(width: 8),
                _buildCircleButton(
                  icon: Icons.add,
                  onPressed: hours < 24 ? () => onHoursChanged(hours + 1) : null,
                ),
              ],
            ),
            // Mins
            Row(
              children: [
                _buildCircleButton(
                  icon: Icons.remove,
                  onPressed: mins >= 10 ? () => onMinsChanged(mins - 10) : null,
                ),
                const SizedBox(width: 8),
                Text(
                  '${mins}m',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.textDark,
                  ),
                ),
                const SizedBox(width: 8),
                _buildCircleButton(
                  icon: Icons.add,
                  onPressed: mins <= 50 ? () => onMinsChanged(mins + 10) : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback? onPressed}) {
    final enabled = onPressed != null;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: enabled ? Colors.white : Colors.grey[200],
        border: Border.all(color: enabled ? Colors.black : Colors.grey[400]!, width: 1.5),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16, color: enabled ? Colors.black : Colors.grey[400]),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildHelpToggle({
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 0,
              offset: const Offset(1.5, 1.5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isExpanded ? Icons.lightbulb : Icons.lightbulb_outline,
              size: 14,
              color: isExpanded ? GelatoTheme.yellowDark : GelatoTheme.textLight,
            ),
            const SizedBox(width: 4),
            Text(
              isExpanded ? 'Hide examples' : 'Show examples',
              style: const TextStyle(
                color: GelatoTheme.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpContent({
    required Color color,
    required Color darkColor,
    required String title,
    required List<String> examples,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, size: 16, color: darkColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: darkColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...examples.map((ex) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: darkColor, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        ex,
                        style: const TextStyle(
                          fontSize: 12,
                          color: GelatoTheme.textDark,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _RiskStepper extends StatelessWidget {
  final int activeStep;

  const _RiskStepper({required this.activeStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(13, (index) {
        if (index.isEven) {
          final stepNum = (index ~/ 2) + 1;
          final isCompleted = stepNum < activeStep;
          final isActive = stepNum == activeStep;

          if (isCompleted) {
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: GelatoTheme.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const Icon(
                Icons.check,
                color: GelatoTheme.greenDark,
                size: 16,
              ),
            );
          } else if (isActive) {
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: GelatoTheme.purple,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2.0),
              ),
              alignment: Alignment.center,
              child: Text(
                '$stepNum',
                style: const TextStyle(
                  color: GelatoTheme.purpleDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            );
          } else {
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.0),
              ),
              alignment: Alignment.center,
              child: Text(
                '$stepNum',
                style: const TextStyle(
                  color: GelatoTheme.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            );
          }
        } else {
          final stepBefore = index ~/ 2 + 1;
          final isCompleted = stepBefore < activeStep;

          return Container(
            width: 14,
            height: 2,
            color: isCompleted ? Colors.black : Colors.black26,
          );
        }
      }),
    );
  }
}
