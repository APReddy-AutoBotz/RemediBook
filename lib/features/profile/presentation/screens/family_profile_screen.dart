import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/core/widgets/sanctuary_glass_card.dart';
import 'package:remedibook/core/models/user_profile.dart'; // Updated model

class FamilyProfileScreen extends StatefulWidget {
  const FamilyProfileScreen({super.key});

  @override
  State<FamilyProfileScreen> createState() => _FamilyProfileScreenState();
}

class _FamilyProfileScreenState extends State<FamilyProfileScreen> {
  // Mock data simulating SovereignProfile.familyMembers
  final List<FamilyMember> _members = [
    FamilyMember(id: '0', name: 'Me (Self)', relation: 'Self', age: 34),
    FamilyMember(id: '1', name: 'Aarav', relation: 'Child', age: 5, allergies: ['Peanuts']),
    FamilyMember(id: '2', name: 'Nani', relation: 'Elder', age: 72, conditions: ['Hypertension']),
  ];
  
  String _activeMemberId = '0'; // Default to Self

  void _setActiveMember(String id) {
    setState(() {
      _activeMemberId = id;
    });
    // In real app, this would update a global Riverpod provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Active Profile Switched")),
    );
  }

  void _addMember() {
    // Stub for add dialog
     setState(() {
      _members.add(FamilyMember(
        id: DateTime.now().toString(),
        name: 'Updates via Dialog',
        relation: 'Spouse',
        age: 30,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Family Circle",
              style: GoogleFonts.crimsonPro(
                fontSize: 28,
                color: RemediTheme.deepTeal,
              ),
            ),
            const SizedBox(height: 8),
              Text(
                "Select a profile to customize safety warnings and dosages.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.4,
                  color: RemediTheme.charcoal.withOpacity(0.6),
                ),
              ),
            const SizedBox(height: 24),
            
            // Add Member Button (Small, aligned right usually, or big card)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addMember,
                icon: const Icon(Icons.add_circle_outline, color: RemediTheme.emberGold),
                label: Text(
                  "Add Family Member",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: RemediTheme.emberGold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Members Grid/List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _members.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final member = _members[index];
                final isActive = member.id == _activeMemberId;
                
                return GestureDetector(
                  onTap: () => _setActiveMember(member.id),
                  child: SanctuaryGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Avatar / Circle
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isActive ? RemediTheme.emberGold : Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive ? Colors.transparent : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              member.name[0],
                              style: GoogleFonts.crimsonPro(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isActive ? Colors.white : RemediTheme.deepTeal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: RemediTheme.charcoal,
                                ),
                              ),
                              Text(
                                "${member.relation} • ${member.age} yrs",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: RemediTheme.charcoal.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: RemediTheme.deepTeal,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Active",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
