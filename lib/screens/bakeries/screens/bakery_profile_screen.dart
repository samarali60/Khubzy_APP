import 'package:flutter/material.dart';
import 'package:khubzy/core/constants/colors.dart';
import 'package:khubzy/core/widgets/logout_button.dart';
import 'package:khubzy/core/widgets/profile_info_card.dart';
import 'package:khubzy/core/widgets/section_title.dart';
import 'package:khubzy/models/baker_model.dart';
import 'package:khubzy/models/bakery_model.dart';
import 'package:khubzy/screens/auth/provider/bakery_provider.dart';
import 'package:khubzy/screens/bakeries/providers/baker_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BakeryProfileScreen extends StatefulWidget {
  const BakeryProfileScreen({super.key});

  @override
  State<BakeryProfileScreen> createState() => _BakeryProfileScreenState();
}

class _BakeryProfileScreenState extends State<BakeryProfileScreen> {
  bool _isLoading = true;
  BakerModel? _baker;
  BakeryModel? _bakery;
  String? _phone;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final bakeryProvider = Provider.of<BakeryProvider>(context, listen: false);
    final bakerProvider = Provider.of<BakerProvider>(context, listen: false);

    await bakeryProvider.loadBakeries();
    await bakerProvider.loadBakers();

    final prefs = await SharedPreferences.getInstance();
    final bakerId = prefs.getString('baker_id');
    final phone = prefs.getString('bakery_phone');

    if (bakerId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) {
      setState(() {
        _bakery = bakeryProvider.getBakeryByOwner(bakerId);
        _baker = bakerProvider.getBakerByNationalId(bakerId);
        _phone = phone;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("الملف الشخصي")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_bakery == null || _baker == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("الملف الشخصي")),
        body: const Center(
          child: Text('لم يتم العثور على بيانات المخبز.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("الملف الشخصي")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeader(theme),
            const SizedBox(height: 24),

            // Bakery Information
            const SectionTitle(title: 'بيانات المخبز'),
            const SizedBox(height: 8),
            ProfileInfoCard(
              label: "اسم المخبز",
              value: _bakery!.bakeryName,
              icon: Icons.storefront_outlined,
              theme: theme,
            ),
            ProfileInfoCard(
              label: "عنوان المخبز",
              value: _bakery!.location,
              icon: Icons.location_on_outlined,
              theme: theme,
            ),
            ProfileInfoCard(
              label: "الحصة اليومية",
              value: "${_bakery!.dailyQuota} رغيف",
              icon: Icons.local_offer_outlined,
              theme: theme,
            ),
            const SizedBox(height: 24),

            // Owner Information
            const SectionTitle(title: 'بيانات المالك'),
            const SizedBox(height: 8),
            ProfileInfoCard(
              label: "اسم المالك",
              value: _baker!.name,
              icon: Icons.person_outline,
              theme: theme,
            ),
            ProfileInfoCard(
              label: "الرقم القومي للمالك",
              value: _baker!.nationalId,
              icon: Icons.badge_outlined,
              theme: theme,
            ),
            if (_phone != null)
              ProfileInfoCard(
                label: "رقم الهاتف",
                value: _phone!,
                icon: Icons.phone_android,
                theme: theme,
              ),

            const SizedBox(height: 32),
            logoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.5),
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
            child: Icon(Icons.bakery_dining_outlined,
                size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _bakery!.bakeryName, // Display bakery's name in header
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}