import 'package:flutter/material.dart';
import 'package:khubzy/core/widgets/error_snackbar.dart';
import 'package:khubzy/core/widgets/welcome_snackbar.dart';
import 'package:khubzy/routes/app_routes.dart';
import 'package:khubzy/screens/auth/provider/bakery_provider.dart';
import 'package:khubzy/screens/bakeries/providers/baker_provider.dart';
import 'package:khubzy/screens/bakeries/screens/bakery_main_layout_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BakerySignupScreen extends StatefulWidget {
  const BakerySignupScreen({super.key});

  @override
  State<BakerySignupScreen> createState() => _BakeryLoginScreenState();
}

class _BakeryLoginScreenState extends State<BakerySignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedBakeryName;
  String? _selectedLocation;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BakeryProvider>(context, listen: false).loadBakeries();
    });
  }

  @override
  void dispose() {
    _nationalIdController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final nationalId = _nationalIdController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();
    final bakeryName = _selectedBakeryName;
    final location = _selectedLocation;

    final bakeryProvider = Provider.of<BakeryProvider>(context, listen: false);
    final bakerProvider = Provider.of<BakerProvider>(context, listen: false);

    // Ensure data is loaded before proceeding
    await bakeryProvider.loadBakeries();
    await bakerProvider.loadBakers();

    // Check if the provided details match a real bakery owner
    final baker = bakerProvider.getBakerByNationalId(nationalId);
    final bakery = bakeryProvider.getBakeryByOwner(nationalId);

    // The baker must exist and the selected bakery details must match
    if (baker != null &&
        bakery != null &&
        bakery.bakeryName == bakeryName &&
        bakery.location == location) {
      final prefs = await SharedPreferences.getInstance();

      // --- THE FIX: Save the National ID for the login screen to use ---
      await prefs.setString('bakery_national_id', nationalId);
      await prefs.setString('bakery_password', password);
      
      // Also save other important info
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_type', 'bakery');
      await prefs.setString('baker_id', nationalId); // For profile screen
      await prefs.setString('baker_name', baker.name);
      await prefs.setString('bakery_name', bakery.bakeryName);
      await prefs.setString('bakery_location', bakery.location);
      await prefs.setString('bakery_phone', phone);


      // Log in the user to set the provider state
      bakeryProvider.loginBakery(
        nationalId: nationalId,
        location: bakery.location,
        bakeryName: bakery.bakeryName,
      );

      WelcomeSnackbar.show(context, bakery.bakeryName);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BakaryMainLayout()),
        (route) => false,
      );
    } else {
      ErrorSnackBar.show(context, "بيانات التسجيل غير صحيحة أو غير متطابقة");
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bakeries = Provider.of<BakeryProvider>(context).bakeries;

    final bakeryNames = bakeries.map((e) => e.bakeryName).toSet().toList();
    final locations = bakeries.map((e) => e.location).toSet().toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'إنشاء حساب مخبز',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nationalIdController,
                label: 'الرقم القومي',
                keyboardType: TextInputType.number,
                maxLength: 14,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'أدخل الرقم القومي';
                  if (!RegExp(r'^\d{14}$').hasMatch(val)) return 'رقم غير صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: 'رقم التليفون',
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'أدخل رقم التليفون';
                  if (!RegExp(r'^(010|011|012|015)[0-9]{8}$').hasMatch(val)) {
                    return 'رقم غير صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _passwordController,
                label: 'كلمة السر',
                obscure: true,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'أدخل كلمة السر';
                  if (val.length < 8) {
                    return 'يجب أن تكون كلمة السر 8 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedBakeryName,
                decoration: InputDecoration(
                  labelText: 'اسم المخبز',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: bakeryNames.map((name) {
                  return DropdownMenuItem(value: name, child: Text(name));
                }).toList(),
                onChanged: _loading
                    ? null
                    : (val) => setState(() => _selectedBakeryName = val),
                validator: (val) => val == null ? 'اختر اسم المخبز' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: InputDecoration(
                  labelText: 'مكان المخبز',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: locations.map((loc) {
                  return DropdownMenuItem(value: loc, child: Text(loc));
                }).toList(),
                onChanged: _loading
                    ? null
                    : (val) => setState(() => _selectedLocation = val),
                validator: (val) => val == null ? 'اختر المكان' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('إنشاء حساب'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'هل لديك حساب بالفعل؟',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.bakeryLogin);
                    },
                    child: Text(
                      'سجّل الدخول',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLength,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscure,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        counterText: '', // Hide the counter
      ),
      validator: validator,
    );
  }
}