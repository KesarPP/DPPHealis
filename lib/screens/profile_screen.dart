import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../data/gelato_theme.dart';
import 'crop_image_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';

// Pastel Color Palette "GELATO DAYS" mapped to GelatoTheme
const Color _pastelPink = GelatoTheme.pink;
const Color _pastelGreen = GelatoTheme.green;
const Color _pastelYellow = GelatoTheme.yellow;
const Color _pastelBlue = GelatoTheme.blue;
const Color _pastelPurple = GelatoTheme.purple;
const Color _pastelPeach = GelatoTheme.orange;
const Color _darkText = GelatoTheme.textDark;

const Color _greenDark = GelatoTheme.greenDark;
const Color _blueDark = GelatoTheme.blueDark;
const Color _purpleDark = GelatoTheme.purpleDark;
const Color _peachDark = GelatoTheme.orangeDark;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(_pastelPink, Colors.white, 0.85), // Soft pastel wash
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: _darkText, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.8),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DotsPainter(color: Colors.black87.withValues(alpha: 0.04)),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeader(
              onUpdate: () {
                if (mounted) {
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 32),
            
            const _SectionTitle('Achievements'),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: _StatCard(title: 'Current Phase', value: 'Phase 1', icon: Icons.emoji_events_rounded, color: _pastelBlue, darkColor: _blueDark)),
                SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'Sessions', value: '12 / 16', icon: Icons.menu_book_rounded, color: _pastelPurple, darkColor: _purpleDark)),
                SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'Streak', value: '14 Days', icon: Icons.local_fire_department_rounded, color: _pastelPeach, darkColor: _peachDark)),
              ],
            ),
            const SizedBox(height: 32),

            const _SectionTitle('Settings'),
            const SizedBox(height: 12),
            const _SettingsSection(),
            const SizedBox(height: 32),

            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.black87, width: 1.5)),
                  elevation: 4,
                  shadowColor: Colors.redAccent.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
        ],
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color color;
  const _DotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double gridSize = 16.0;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    for (double x = 0; x <= size.width; x += gridSize) {
      for (double y = 0; y <= size.height; y += gridSize) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) => oldDelegate.color != color;
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _darkText, letterSpacing: -0.8),
    );
  }
}

class ProfileColorSet {
  final Color bg;
  final Color fg;
  const ProfileColorSet({required this.bg, required this.fg});
}

const Map<String, ProfileColorSet> _profileColors = {
  'pink': ProfileColorSet(bg: GelatoTheme.pink, fg: GelatoTheme.pinkDark),
  'green': ProfileColorSet(bg: GelatoTheme.green, fg: GelatoTheme.greenDark),
  'yellow': ProfileColorSet(bg: GelatoTheme.yellow, fg: GelatoTheme.yellowDark),
  'blue': ProfileColorSet(bg: GelatoTheme.blue, fg: GelatoTheme.blueDark),
  'purple': ProfileColorSet(bg: GelatoTheme.purple, fg: GelatoTheme.purpleDark),
  'orange': ProfileColorSet(bg: GelatoTheme.orange, fg: GelatoTheme.orangeDark),
};

class _ProfileHeader extends StatelessWidget {
  final VoidCallback onUpdate;
  const _ProfileHeader({required this.onUpdate});

  void _showEditProfileDialog(BuildContext context, UserProfileData profile) {
    final user = AuthService().currentUser;
    final nameController = TextEditingController(text: profile.displayName);
    final ImagePicker picker = ImagePicker();
    
    // Dialog session state variables
    File? newPickedFile;
    bool isRemoved = false;

    String getInitials(String name) {
      if (name.isEmpty) return 'JP';
      final parts = name.trim().split(' ');
      if (parts.length > 1) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Determine if there is currently an active photo in the dialog state
            final hasPhoto = newPickedFile != null || (profile.localImagePath != null && !isRemoved);
            
            // Set up image provider for the preview
            ImageProvider? previewImageProvider;
            if (newPickedFile != null) {
              previewImageProvider = FileImage(newPickedFile!);
            } else if (profile.localImagePath != null && !isRemoved) {
              previewImageProvider = FileImage(File(profile.localImagePath!));
            }

            return AlertDialog(
              backgroundColor: GelatoTheme.bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.black, width: 2.0),
              ),
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: GelatoTheme.textDark,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar Preview
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black54, width: 2.0),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: GelatoTheme.pink,
                          foregroundImage: previewImageProvider,
                          child: Text(
                            getInitials(nameController.text),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.pinkDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    TextField(
                      controller: nameController,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Photo Customization Options
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: GelatoTheme.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black, width: 1.5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () async {
                        try {
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setDialogState(() {
                              newPickedFile = File(image.path);
                              isRemoved = false;
                            });
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error picking image: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.photo_library_rounded, size: 20),
                      label: Text(hasPhoto ? 'Change Photo' : 'Choose Photo'),
                    ),
                    
                    if (hasPhoto) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Crop current/picked photo
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              side: const BorderSide(color: Colors.black, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            onPressed: () async {
                              final activeFile = newPickedFile ?? File(profile.localImagePath!);
                              final File? croppedFile = await Navigator.push<File>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CropImageScreen(imageFile: activeFile),
                                ),
                              );
                              if (croppedFile != null) {
                                setDialogState(() {
                                  newPickedFile = croppedFile;
                                  isRemoved = false;
                                });
                              }
                            },
                            icon: const Icon(Icons.crop_rounded, size: 18),
                            label: const Text('Crop'),
                          ),
                          const SizedBox(width: 12),
                          // Remove photo
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red[700],
                              side: BorderSide(color: Colors.red[700]!, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            onPressed: () {
                              setDialogState(() {
                                newPickedFile = null;
                                isRemoved = true;
                              });
                            },
                            icon: const Icon(Icons.delete_rounded, size: 18),
                            label: const Text('Remove'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GelatoTheme.green,
                    foregroundColor: GelatoTheme.greenDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.black, width: 1.5),
                    ),
                  ),
                  onPressed: () async {
                    // Commit/persist changes when user saves
                    if (isRemoved) {
                      await AuthService().removeLocalProfileImage();
                    } else if (newPickedFile != null) {
                      await AuthService().saveLocalProfileImage(newPickedFile!);
                    }

                    final newName = nameController.text.trim();
                    if (newName.isNotEmpty) {
                      if (user != null) {
                        await user.updateDisplayName(newName);
                        await user.reload();
                      }
                      await AuthService().persistUserProfile(newName, profile.email);
                    }
                    
                    onUpdate();

                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfileData>(
      future: AuthService().getUserProfileData(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final displayName = profile?.displayName ?? 'Janice Pattice';
        final email = profile?.email ?? '';
        final localPath = profile?.localImagePath;
        
        ImageProvider? imageProvider;
        if (localPath != null) {
          imageProvider = FileImage(File(localPath));
        }

        String getInitials(String name) {
          if (name.isEmpty) return 'JP';
          final parts = name.trim().split(' ');
          if (parts.length > 1) {
            return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
          }
          return parts[0][0].toUpperCase();
        }
        final initials = getInitials(displayName);

        final String bgName = profile?.profileBgColor ?? 'pink';
        final colorSet = _profileColors[bgName] ?? _profileColors['pink']!;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorSet.fg, width: 4), // Matching Accent Circle
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black87, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: colorSet.bg,
                  foregroundImage: imageProvider,
                  onForegroundImageError: imageProvider != null
                      ? (exception, stackTrace) {
                          // Silently handle error and fallback to initials
                        }
                      : null,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: colorSet.fg,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _darkText, letterSpacing: -0.8),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _pastelYellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'On a 14-day winning streak!',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    if (profile != null) {
                      _showEditProfileDialog(context, profile);
                    }
                  },
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit Profile'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _pastelBlue,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.black87, width: 1.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Customize Avatar Theme',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _darkText, letterSpacing: -0.5),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _profileColors.keys.map((colorName) {
                final cSet = _profileColors[colorName]!;
                final isSelected = bgName == colorName;
                
                return GestureDetector(
                  onTap: () async {
                    await AuthService().persistProfileBgColor(colorName);
                    onUpdate();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cSet.bg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.black26,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: cSet.fg,
                            size: 18,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final String target;
  final String current;
  final double progress;
  final IconData icon;
  final Color color;
  final Color darkColor;

  const _GoalCard({required this.title, required this.target, required this.current, required this.progress, required this.icon, required this.color, required this.darkColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20), // Increased padding
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black87, width: 1.2),
                ),
                child: Icon(icon, color: darkColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _darkText, letterSpacing: -0.5))),
            ],
          ),
          const SizedBox(height: 20),
          Text(target, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _darkText)),
          const SizedBox(height: 4),
          Text(current, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: darkColor)),
          const SizedBox(height: 16),
          // Pill styled gradient progress bar
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: darkColor,
                      boxShadow: [
                        BoxShadow(color: darkColor.withValues(alpha: 0.5), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color darkColor;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color, required this.darkColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black87, width: 1.2),
            ),
            child: Icon(icon, color: darkColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: _darkText, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _darkText.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _JourneyProgressCard extends StatelessWidget {
  const _JourneyProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _pastelPurple,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(color: _pastelPurple.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overall Journey', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _darkText, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('12 of 17 milestones', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _darkText.withValues(alpha: 0.7))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black87, width: 1.5),
                ),
                child: const Text('68%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _darkText)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.68,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _purpleDark,
                          boxShadow: [
                            BoxShadow(color: _pastelPurple.withValues(alpha: 0.5), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: MediaQuery.of(context).size.width * 0.32 - 40,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: _pastelPeach.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.star_rounded, color: _purpleDark, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection();

  @override
  Widget build(BuildContext context) {
    return const _WhiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _ActionTile(icon: Icons.show_chart_rounded, title: 'Weight Journey', color: _pastelBlue),
          Divider(height: 1, color: Colors.black12, indent: 60),
          _ActionTile(icon: Icons.science_rounded, title: 'Lab Results', color: _pastelPurple),
          Divider(height: 1, color: Colors.black12, indent: 60),
          _ActionTile(icon: Icons.fact_check_rounded, title: 'Risk Assessments', color: _pastelPeach),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatefulWidget {
  const _SettingsSection();

  @override
  State<_SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<_SettingsSection> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      });
    }
  }

  Future<void> _toggleNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
      });
    }

    if (enabled) {
      await NotificationService().requestPermissions();
      NotificationService().startChatListener();
    } else {
      // Cancel all active local notifications when disabled
      final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
      await plugin.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _pastelGreen, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.notifications_active_rounded, color: Colors.black54, size: 20),
            ),
            title: const Text('Notifications', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
            trailing: Switch(
              value: _notificationsEnabled, 
              onChanged: _toggleNotifications, 
              activeThumbColor: _pastelBlue
            ),
          ),
          const Divider(height: 1, color: Colors.black12, indent: 60),
          const _ActionTile(icon: Icons.privacy_tip_rounded, title: 'Privacy', color: Colors.black54),
          const Divider(height: 1, color: Colors.black12, indent: 60),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _pastelGreen, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.language_rounded, color: Colors.black54, size: 20),
            ),
            title: const Text('Language', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
            trailing: const Text('English', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _ActionTile({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black54),
      onTap: () {},
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _WhiteCard({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }
}
