import 'package:flutter/material.dart';
import 'package:khubzy/core/constants/colors.dart';
import 'package:khubzy/routes/app_routes.dart';
import 'package:khubzy/screens/auth/provider/citizen_auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:khubzy/screens/auth/provider/citizen_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final citizen = Provider.of<CitizenProvider>(context).currentCitizen;

    if (citizen == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("الملف الشخصي")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // رأس البطاقة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor:AppColors.primary,
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

            // بيانات المواطن
            _buildInfoCard(
              "الرقم القومي",
              citizen.nationalId,
              Icons.badge_outlined,
              theme,
            ),
            _buildInfoCard(
              "رقم الهاتف",
              citizen.phone,
              Icons.phone_android,
              theme,
            ),
            _buildInfoCard(
              "رقم البطاقة التموينية",
              citizen.cardId,
              Icons.credit_card,
              theme,
            ),
            _buildInfoCard(
              "عدد أفراد البطاقة التموينية",
              "${citizen.familyMembers}",
              Icons.group,
              theme,
            ),
            const SizedBox(height: 12),
            Divider(thickness: 1, color: Colors.brown.shade200),
            const SizedBox(height: 12),
            _buildInfoCard(
              "الحد الشهري للخبز",
              "${citizen.monthlyBreadQuota} رغيف",
              Icons.local_offer_outlined,
              theme,
            ),
            _buildInfoCard(
              "الحصة اليومية للفرد",
              "${5} رغيف",
              Icons.calendar_today,
              theme,
            ),

            //  _buildInfoCard("المتاح يوميًا", "${citizen.availableBreadPerDay} رغيف", Icons.calendar_today, theme),
            // _buildInfoCard("المستهلك حتى الآن", "${citizen.availableBread} رغيف", Icons.bar_chart, theme),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => logoutDialog(context),
                  icon: const Icon(Icons.logout, size: 22),
                  label: const Text(
                    "تسجيل الخروج",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> logoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "تسجيل الخروج",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                "هل أنت متأكد أنك تريد تسجيل الخروج؟",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("إلغاء"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        await authProvider.logout();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.splash,
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("خروج"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.brown.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
