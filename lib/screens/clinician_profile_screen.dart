import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../models/coach_profile.dart';
import 'crop_image_screen.dart';

const _brandColor = Color(0xFF1B3D6D);
const _slateGrey = Color(0xFF6B7C93);

class ClinicianProfileScreen extends StatefulWidget {
  final bool isViewOnly;
  const ClinicianProfileScreen({super.key, this.isViewOnly = false});

  @override
  State<ClinicianProfileScreen> createState() => _ClinicianProfileScreenState();
}

class _ClinicianProfileScreenState extends State<ClinicianProfileScreen> {
  final _authService = AuthService();
  CoachProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _authService.currentUser;
      final uid = user?.uid ?? 'default_coach';
      final profile = await _authService.getCoachProfile(uid);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile(CoachProfile updatedProfile) async {
    setState(() => _isLoading = true);
    await _authService.saveCoachProfile(updatedProfile);
    setState(() {
      _profile = updatedProfile;
      _isLoading = false;
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'CM';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  IconData _getCredentialIcon(String iconKey) {
    switch (iconKey) {
      case 'verified':
        return Icons.verified_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'premium':
        return Icons.workspace_premium_outlined;
      default:
        return Icons.workspace_premium_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: _brandColor),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_brandColor),
              ),
            )
          : Stack(
              children: [
                // Background curved header
                ClipPath(
                  child: Image.asset(
                    'assets/images/coach_profile_bg.png',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE5E9F0), Color(0xFFF1F5F9)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Scrollable Profile Content
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 100), // Push content down to overlap the header

                      // Avatar
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFFEBF3FC),
                            foregroundImage: (_profile?.localImagePath != null &&
                                    File(_profile!.localImagePath!).existsSync())
                                ? FileImage(File(_profile!.localImagePath!))
                                : null,
                            child: Text(
                              _getInitials(_profile?.name ?? 'Coach'),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: _brandColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name & Subtitle
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _profile?.name ?? 'Coach Profile',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _brandColor,
                              ),
                            ),
                            if (!widget.isViewOnly) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _editGeneralInfo(context),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Color(0xFF1A73E8),
                                  size: 20,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          (_profile?.title == null || _profile!.title.isEmpty)
                              ? (widget.isViewOnly ? 'Senior Health Coach' : 'Add a title / role')
                              : _profile!.title,
                          style: TextStyle(
                            fontSize: 14,
                            color: _slateGrey,
                            fontWeight: FontWeight.w500,
                            fontStyle: (_profile?.title == null || _profile!.title.isEmpty)
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Profile Cards Group
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildProfileCard(
                              title: 'About',
                              onEditTap: () => _editAbout(context),
                              child: Text(
                                (_profile?.about == null || _profile!.about.isEmpty)
                                    ? (widget.isViewOnly
                                        ? 'No bio details available.'
                                        : 'No bio added yet. Tap the edit icon to write a bio.')
                                    : _profile!.about,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _slateGrey,
                                  height: 1.5,
                                  fontStyle: (_profile?.about == null || _profile!.about.isEmpty)
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                            ),

                            _buildProfileCard(
                              title: 'Specializations',
                              onEditTap: () => _editSpecializations(context),
                              child: (_profile?.specializations == null || _profile!.specializations.isEmpty)
                                  ? Text(
                                      widget.isViewOnly
                                          ? 'No specializations listed.'
                                          : 'No specializations added yet. Tap edit to add some.',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: _slateGrey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _profile!.specializations
                                          .map((spec) => _buildSpecializationChip(spec))
                                          .toList(),
                                    ),
                            ),

                            _buildProfileCard(
                              title: 'Credentials & Certifications',
                              onEditTap: () => _editCredentials(context),
                              child: (_profile?.credentials == null || _profile!.credentials.isEmpty)
                                  ? Text(
                                      widget.isViewOnly
                                          ? 'No credentials listed.'
                                          : 'No credentials added yet. Tap edit to add some.',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: _slateGrey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    )
                                  : Column(
                                      children: _profile!.credentials
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            final idx = entry.key;
                                            final cred = entry.value;
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: idx == _profile!.credentials.length - 1 ? 0 : 16,
                                              ),
                                              child: _buildCredentialRow(
                                                icon: _getCredentialIcon(cred['icon'] ?? ''),
                                                title: cred['title'] ?? '',
                                                subtitle: cred['subtitle'] ?? '',
                                              ),
                                            );
                                          })
                                          .toList(),
                                    ),
                            ),

                            if (!widget.isViewOnly) ...[
                              const SizedBox(height: 24),
                              // Sign Out Button
                              OutlinedButton.icon(
                                icon: const Icon(Icons.logout_rounded, color: Color(0xFFD32F2F)),
                                label: const Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFFD32F2F),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  _authService.signOut();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    (_) => false,
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileCard({
    required String title,
    required Widget child,
    VoidCallback? onEditTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _brandColor,
                ),
              ),
              if (!widget.isViewOnly && onEditTap != null)
                GestureDetector(
                  onTap: onEditTap,
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFF1A73E8),
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSpecializationChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD2EC82),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF3B571B),
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildCredentialRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEBF3FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1A73E8),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: _slateGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Modal Edit Workflows ──────────────────────────────────────────────────

  void _editGeneralInfo(BuildContext context) {
    if (_profile == null) return;

    final nameController = TextEditingController(text: _profile!.name);
    final titleController = TextEditingController(text: _profile!.title);
    String? tempLocalImagePath = _profile!.localImagePath;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final hasPhoto = tempLocalImagePath != null && File(tempLocalImagePath!).existsSync();

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Edit General Info',
                style: TextStyle(fontWeight: FontWeight.bold, color: _brandColor),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _brandColor, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFFEBF3FC),
                              foregroundImage: hasPhoto ? FileImage(File(tempLocalImagePath!)) : null,
                              child: Text(
                                _getInitials(nameController.text),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _brandColor,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () async {
                                final ImagePicker picker = ImagePicker();
                                try {
                                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    final File? croppedFile = await Navigator.push<File>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CropImageScreen(imageFile: File(image.path)),
                                      ),
                                    );
                                    if (croppedFile != null) {
                                      final savedPath = await _authService.saveLocalProfileImage(croppedFile);
                                      if (savedPath != null) {
                                        setDialogState(() {
                                          tempLocalImagePath = savedPath;
                                        });
                                      }
                                    }
                                  }
                                } catch (_) {}
                              },
                              child: const CircleAvatar(
                                radius: 14,
                                backgroundColor: _brandColor,
                                child: Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasPhoto) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setDialogState(() {
                            tempLocalImagePath = null;
                          });
                        },
                        child: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title / Role',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel', style: TextStyle(color: _slateGrey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updated = CoachProfile(
                      uid: _profile!.uid,
                      name: nameController.text.trim(),
                      email: _profile!.email,
                      title: titleController.text.trim(),
                      about: _profile!.about,
                      specializations: _profile!.specializations,
                      credentials: _profile!.credentials,
                      localImagePath: tempLocalImagePath,
                    );
                    Navigator.pop(dialogContext);
                    _saveProfile(updated);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editAbout(BuildContext context) {
    if (_profile == null) return;

    final aboutController = TextEditingController(text: _profile!.about);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit About Bio',
            style: TextStyle(fontWeight: FontWeight.bold, color: _brandColor),
          ),
          content: TextField(
            controller: aboutController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter your bio details...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: _slateGrey)),
            ),
            ElevatedButton(
              onPressed: () {
                final updated = CoachProfile(
                  uid: _profile!.uid,
                  name: _profile!.name,
                  email: _profile!.email,
                  title: _profile!.title,
                  about: aboutController.text.trim(),
                  specializations: _profile!.specializations,
                  credentials: _profile!.credentials,
                  localImagePath: _profile!.localImagePath,
                );
                Navigator.pop(dialogContext);
                _saveProfile(updated);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editSpecializations(BuildContext context) {
    if (_profile == null) return;

    List<String> tempSpecs = List<String>.from(_profile!.specializations);
    final specController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Edit Specializations',
                style: TextStyle(fontWeight: FontWeight.bold, color: _brandColor),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tempSpecs
                          .map(
                            (spec) => Chip(
                              label: Text(spec),
                              onDeleted: () {
                                setDialogState(() {
                                  tempSpecs.remove(spec);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: specController,
                            decoration: const InputDecoration(
                              labelText: 'New Specialization',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: _brandColor, size: 32),
                          onPressed: () {
                            final text = specController.text.trim();
                            if (text.isNotEmpty && !tempSpecs.contains(text)) {
                              setDialogState(() {
                                tempSpecs.add(text);
                                specController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel', style: TextStyle(color: _slateGrey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updated = CoachProfile(
                      uid: _profile!.uid,
                      name: _profile!.name,
                      email: _profile!.email,
                      title: _profile!.title,
                      about: _profile!.about,
                      specializations: tempSpecs,
                      credentials: _profile!.credentials,
                      localImagePath: _profile!.localImagePath,
                    );
                    Navigator.pop(dialogContext);
                    _saveProfile(updated);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editCredentials(BuildContext context) {
    if (_profile == null) return;

    List<Map<String, String>> tempCreds =
        _profile!.credentials.map((c) => Map<String, String>.from(c)).toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Edit Credentials',
                style: TextStyle(fontWeight: FontWeight.bold, color: _brandColor),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...tempCreds.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final cred = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(_getCredentialIcon(cred['icon'] ?? ''), color: _brandColor),
                            title: Text(
                              cred['title'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(cred['subtitle'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                                  onPressed: () => _addOrEditCredentialSubDialog(context, cred, (updatedCred) {
                                    setDialogState(() {
                                      tempCreds[idx] = updatedCred;
                                    });
                                  }),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                                  onPressed: () {
                                    setDialogState(() {
                                      tempCreds.removeAt(idx);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _addOrEditCredentialSubDialog(context, null, (newCred) {
                          setDialogState(() {
                            tempCreds.add(newCred);
                          });
                        }),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Credential'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _brandColor,
                          side: const BorderSide(color: _brandColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel', style: TextStyle(color: _slateGrey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updated = CoachProfile(
                      uid: _profile!.uid,
                      name: _profile!.name,
                      email: _profile!.email,
                      title: _profile!.title,
                      about: _profile!.about,
                      specializations: _profile!.specializations,
                      credentials: tempCreds,
                      localImagePath: _profile!.localImagePath,
                    );
                    Navigator.pop(dialogContext);
                    _saveProfile(updated);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addOrEditCredentialSubDialog(
    BuildContext context,
    Map<String, String>? initialData,
    Function(Map<String, String>) onSave,
  ) {
    final titleController = TextEditingController(text: initialData?['title'] ?? '');
    final subtitleController = TextEditingController(text: initialData?['subtitle'] ?? '');
    String selectedIcon = initialData?['icon'] ?? 'verified';

    showDialog(
      context: context,
      builder: (subDialogContext) {
        return StatefulBuilder(
          builder: (context, setSubState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                initialData == null ? 'Add Credential' : 'Edit Credential',
                style: const TextStyle(fontWeight: FontWeight.bold, color: _brandColor),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle (e.g. Institution)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Choose Icon', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIconButtonChoice('verified', Icons.verified_outlined, selectedIcon, (val) {
                          setSubState(() => selectedIcon = val);
                        }),
                        _buildIconButtonChoice('school', Icons.school_outlined, selectedIcon, (val) {
                          setSubState(() => selectedIcon = val);
                        }),
                        _buildIconButtonChoice('premium', Icons.workspace_premium_outlined, selectedIcon, (val) {
                          setSubState(() => selectedIcon = val);
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(subDialogContext),
                  child: const Text('Cancel', style: TextStyle(color: _slateGrey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final t = titleController.text.trim();
                    final s = subtitleController.text.trim();
                    if (t.isNotEmpty) {
                      onSave({
                        'title': t,
                        'subtitle': s,
                        'icon': selectedIcon,
                      });
                      Navigator.pop(subDialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildIconButtonChoice(
    String key,
    IconData icon,
    String selectedKey,
    Function(String) onSelected,
  ) {
    final isSelected = selectedKey == key;
    return GestureDetector(
      onTap: () => onSelected(key),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? _brandColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? _brandColor : Colors.grey.shade300, width: 2),
        ),
        child: Icon(icon, color: isSelected ? _brandColor : Colors.grey, size: 28),
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
