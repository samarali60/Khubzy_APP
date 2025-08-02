import 'package:flutter/material.dart';
import 'package:khubzy/core/widgets/error_snackbar.dart';
import 'package:khubzy/core/widgets/welcome_snackbar.dart';
import 'package:khubzy/screens/auth/provider/bakery_provider.dart';
import 'package:khubzy/screens/bakeries/providers/baker_provider.dart';
import 'package:khubzy/screens/bakeries/screens/bakery_main_layout_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BakerySignupScreen extends StatefulWidget {
  const BakerySignupScreen({super.key});

  @override
  State<BakerySignupScreen> createState() => _BakerySignupScreenState();
}

class _BakerySignupScreenState extends State<BakerySignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BakeryProvider>(context, listen: false).loadBakeries();
      Provider.of<BakerProvider>(context, listen: false).loadBakers();
    });
  }

  @override
  void dispose() {
    _nationalIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final nationalId = _nationalIdController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final phone = _phoneController.text.trim();

    if (password != confirmPassword) {
      ErrorSnackBar.show(context, 'كلمة السر وتأكيدها غير متطابقين');
      return;
    }

    setState(() => _loading = true);

    final bakeryProvider = Provider.of<BakeryProvider>(context, listen: false);
    final bakerProvider = Provider.of<BakerProvider>(context, listen: false);

    final baker = bakerProvider.getBakerByNationalId(nationalId);
    final bakery = bakeryProvider.getBakeryByOwner(nationalId);

    if (baker != null && bakery != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('bakery_national_id', nationalId);
      await prefs.setString('bakery_password', password);
      await prefs.setString('bakery_phone', phone);
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_type', 'bakery');
      await prefs.setString('baker_id', nationalId);
      await prefs.setString('baker_name', baker.name);
      await prefs.setString('bakery_name', bakery.bakeryName);
      await prefs.setString('bakery_location', bakery.location);

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
      ErrorSnackBar.show(
          context, 'بيانات التسجيل غير صحيحة أو المخبز غير موجود');
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
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
                  if (!RegExp(r'^\d{14}$').hasMatch(val)) {
                    return 'رقم غير صحيح';
                  }
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
                obscure: _obscurePassword,
                maxLength: 8,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(() {
                    _obscurePassword = !_obscurePassword;
                  }),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'أدخل كلمة السر';
                  if (val.length != 8) return 'كلمة السر يجب أن تكون 8 أحرف بالضبط';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _confirmPasswordController,
                label: 'تأكيد كلمة السر',
                obscure: _obscureConfirmPassword,
                maxLength: 8,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  }),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'أدخل تأكيد كلمة السر';
                  if (val.length != 8) return 'كلمة السر يجب أن تكون 8 أحرف بالضبط';
                  if (val != _passwordController.text)
                    return 'كلمة السر غير متطابقة';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('إنشاء حساب'),
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
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLength: maxLength,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        counterText: '',
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
