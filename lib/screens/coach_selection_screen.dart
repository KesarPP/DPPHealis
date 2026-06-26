import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/gelato_theme.dart';
import '../main.dart'; // To access MainShell

class CoachSelectionScreen extends StatefulWidget {
  const CoachSelectionScreen({super.key});

  @override
  State<CoachSelectionScreen> createState() => _CoachSelectionScreenState();
}

class _CoachSelectionScreenState extends State<CoachSelectionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _coaches = [];
  bool _isLoading = true;
  String? _selectedCoachId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchCoaches();
  }

  Future<void> _fetchCoaches() async {
    try {
      final snapshot = await _firestore.collection('coaches').get();
      
      List<Map<String, dynamic>> loadedCoaches = [];
      
      // Add the "Let Us Decide" option first
      loadedCoaches.add({
        'id': 'ADMIN_PENDING',
        'name': 'Let Us Decide',
        'email': '',
        'specialty': 'We will assign the best coach for you',
        'about': 'Skip the choice and let our matching algorithm find the perfect coach for your specific needs and goals.',
        'assignedCount': 0,
        'isFull': false,
        'isCustom': true,
      });

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final coachId = doc.id;
        
        // Count how many users are assigned to this coach
        final countQuery = await _firestore
            .collection('users')
            .where('assignedCoachId', isEqualTo: coachId)
            .count()
            .get();
        
        final assignedCount = countQuery.count ?? 0;
        
        loadedCoaches.add({
          'id': coachId,
          'name': data['name'] ?? 'Unnamed Coach',
          'email': data['email'] ?? '',
          'specialty': data['specialty'] ?? 'Diabetes Prevention Coach',
          'about': data['about'] ?? 'I am dedicated to helping you achieve your health goals through personalized guidance, continuous support, and actionable steps tailored to your lifestyle.',
          'assignedCount': assignedCount,
          'isFull': assignedCount >= 10,
          'isCustom': false,
        });
      }

      setState(() {
        _coaches = loadedCoaches;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching coaches: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSelection() async {
    if (_selectedCoachId == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'assignedCoachId': _selectedCoachId,
        });
      }
      
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (e) {
      debugPrint('Error saving coach selection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save selection: $e')),
      );
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        backgroundColor: GelatoTheme.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Select Your Coach',
          style: TextStyle(
            color: GelatoTheme.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: GelatoTheme.purpleDark))
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Swipe left or right to explore coaches. Swipe up on a card to read more about them.',
                    style: TextStyle(
                      fontSize: 15,
                      color: GelatoTheme.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    itemCount: _coaches.length,
                    controller: PageController(viewportFraction: 0.85),
                    itemBuilder: (context, index) {
                      final c = _coaches[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                        child: CoachSwipeCard(
                          coach: c,
                          isSelected: _selectedCoachId == c['id'],
                          onSelect: () {
                            if (c['isFull'] != true) {
                              setState(() {
                                _selectedCoachId = c['id'];
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Bottom Action Area
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                    color: GelatoTheme.bg,
                    border: Border(top: BorderSide(color: Colors.black, width: 2.0)),
                  ),
                  child: ElevatedButton(
                    onPressed: _selectedCoachId == null || _isSaving ? null : _saveSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GelatoTheme.purple,
                      foregroundColor: GelatoTheme.purpleDark,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: _selectedCoachId == null ? Colors.transparent : Colors.black, width: 2.0),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: GelatoTheme.purpleDark, strokeWidth: 2))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Complete Setup',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.check_circle_outline, size: 20),
                          ],
                        ),
                  ),
                ),
              ],
            ),
    );
  }
}

class CoachSwipeCard extends StatefulWidget {
  final Map<String, dynamic> coach;
  final bool isSelected;
  final VoidCallback onSelect;

  const CoachSwipeCard({
    super.key,
    required this.coach,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  State<CoachSwipeCard> createState() => _CoachSwipeCardState();
}

class _CoachSwipeCardState extends State<CoachSwipeCard> {
  bool _showAbout = false;

  @override
  void didUpdateWidget(covariant CoachSwipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coach['id'] != widget.coach['id']) {
      // Reset state when swiping to a new card
      _showAbout = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFull = widget.coach['isFull'] == true;
    final isCustom = widget.coach['isCustom'] == true;
    
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < -300) {
          // Swipe up
          setState(() => _showAbout = true);
        } else if (details.primaryVelocity! > 300) {
          // Swipe down
          setState(() => _showAbout = false);
        }
      },
      onTap: widget.onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isFull ? Colors.grey.shade200 : (widget.isSelected ? GelatoTheme.green : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isSelected ? Colors.black : Colors.black87,
            width: widget.isSelected ? 3.0 : 2.0,
          ),
          boxShadow: isFull ? [] : [
            BoxShadow(
              color: Colors.black,
              offset: widget.isSelected ? const Offset(2, 2) : const Offset(4, 4),
              blurRadius: 0,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Front Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: isCustom ? GelatoTheme.purple : GelatoTheme.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: Center(
                        child: Icon(
                          isCustom ? Icons.auto_awesome : Icons.person,
                          color: Colors.black,
                          size: 60,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.coach['name'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isFull ? Colors.grey.shade600 : GelatoTheme.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.coach['specialty'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isFull ? Colors.grey.shade500 : GelatoTheme.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (!isCustom)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isFull ? Colors.red.shade100 : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Text(
                          isFull ? 'FULL' : '${widget.coach['assignedCount']}/10 assigned',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.black54,
                      size: 32,
                    ),
                    const Text(
                      'Swipe up to learn more',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Back/About Content (Slides up)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: _showAbout ? 0 : MediaQuery.of(context).size.height,
                bottom: _showAbout ? 0 : -MediaQuery.of(context).size.height,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'About',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down, size: 32, color: Colors.black),
                            onPressed: () => setState(() => _showAbout = false),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.black26, thickness: 2),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            widget.coach['about'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: GelatoTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                      if (widget.isSelected)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: GelatoTheme.green,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: const Text(
                            'Selected',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        )
                      else if (!isFull)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onSelect();
                              setState(() => _showAbout = false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GelatoTheme.blue,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.black, width: 2),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Select Coach',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

