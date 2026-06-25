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
          'assignedCount': assignedCount,
          'isFull': assignedCount >= 10,
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
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      const Text(
                        'Choose a dedicated coach to guide you on your journey, or let us assign the best fit for you.',
                        style: TextStyle(
                          fontSize: 15,
                          color: GelatoTheme.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // "Let Admin Decide" Option
                      _buildCoachCard(
                        id: 'ADMIN_PENDING',
                        name: 'Let Us Decide',
                        specialty: 'We will assign the best coach for you',
                        isFull: false,
                        assignedCount: 0,
                        isCustom: true,
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Row(
                          children: [
                            Expanded(child: Divider(color: Colors.black26)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text('OR CHOOSE BELOW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black54)),
                            ),
                            Expanded(child: Divider(color: Colors.black26)),
                          ],
                        ),
                      ),
                      
                      ..._coaches.map((c) => _buildCoachCard(
                        id: c['id'],
                        name: c['name'],
                        specialty: c['specialty'],
                        isFull: c['isFull'],
                        assignedCount: c['assignedCount'],
                      )),
                    ],
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

  Widget _buildCoachCard({
    required String id,
    required String name,
    required String specialty,
    required bool isFull,
    required int assignedCount,
    bool isCustom = false,
  }) {
    final bool isSelected = _selectedCoachId == id;
    
    return GestureDetector(
      onTap: isFull ? null : () {
        setState(() {
          _selectedCoachId = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isFull ? Colors.grey.shade300 : (isSelected ? GelatoTheme.green : Colors.white),
          borderRadius: GelatoTheme.cardRadius,
          border: GelatoTheme.cardBorder,
          boxShadow: isFull ? [] : GelatoTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCustom ? GelatoTheme.purple : GelatoTheme.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Center(
                child: Icon(
                  isCustom ? Icons.auto_awesome : Icons.person,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isFull ? Colors.grey.shade500 : GelatoTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isFull ? Colors.grey.shade400 : GelatoTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (!isCustom)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFull ? Colors.red.shade100 : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isFull ? Colors.red.shade300 : Colors.blue.shade300),
                    ),
                    child: Text(
                      isFull ? 'FULL' : '$assignedCount/10',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isFull ? Colors.red.shade700 : Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
