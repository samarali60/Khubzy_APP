import 'package:flutter/material.dart';
import 'package:khubzy/core/constants/colors.dart';
import 'package:khubzy/core/widgets/logout_button.dart';
import 'package:khubzy/core/widgets/profile_info_card.dart';
import 'package:provider/provider.dart';
import 'package:khubzy/screens/auth/provider/citizen_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final citizenProvider = Provider.of<CitizenProvider>(context);
    final isLoading = citizenProvider.isLoading;
    final citizen = citizenProvider.currentCitizen;

    // ✅ حالة التحميل
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ❌ حالة عدم وجود مواطن
    if (citizen == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("الملف الشخصي")),
        body: const Center(
          child: Text(
            "لا يوجد بيانات للمستخدم.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    // ✅ الحالة العادية: مواطن موجود
    return Scaffold(
      appBar: AppBar(title: const Text("الملف الشخصي")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🟦 رأس البطاقة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      citizen.name,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📋 بيانات المواطن
            ProfileInfoCard(
              label: "الرقم القومي",
              value: citizen.nationalId,
              icon: Icons.badge_outlined,
              theme: theme,
            ),
            ProfileInfoCard(
              label: "رقم الهاتف",
              value: citizen.phone,
              icon: Icons.phone_android,
              theme: theme,
            ),
            ProfileInfoCard(
              label: "رقم البطاقة التموينية",
              value: citizen.cardId,
              icon: Icons.credit_card,
              theme: theme,
            ),
            ProfileInfoCard(
              label: "عدد أفراد البطاقة التموينية",
              value: "${citizen.familyMembers}",
              icon: Icons.group,
              theme: theme,
            ),

            const SizedBox(height: 12),
            Divider(thickness: 1, color: Colors.brown.shade200),
            const SizedBox(height: 12),

            // 🍞 بيانات الخبز
            ProfileInfoCard(
              label: "الحد الشهري للخبز",
              value: "${citizen.monthlyBreadQuota} رغيف",
              icon: Icons.local_offer_outlined,
              theme: theme,
            ),
            ProfileInfoCard(
              label: "الحصة اليومية للفرد",
              value: "${citizen.availableBreadPerDay} رغيف",
              icon: Icons.calendar_today,
              theme: theme,
            ),

            const SizedBox(height: 20),

            // 🔓 زر تسجيل الخروج
            logoutButton(),
          ],
        ),
      ),
    );
  }
}
