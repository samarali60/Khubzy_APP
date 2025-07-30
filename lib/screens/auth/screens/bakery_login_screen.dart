import 'package:flutter/material.dart';
import 'package:khubzy/routes/app_routes.dart';
import 'package:khubzy/screens/bakeries/screens/bakery_main_layout_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khubzy/core/widgets/error_snackbar.dart';
import 'package:khubzy/core/widgets/welcome_snackbar.dart';
import 'package:khubzy/screens/auth/provider/bakery_provider.dart';

class BakeryLoginScreen extends StatefulWidget {
  const BakeryLoginScreen({super.key});

  @override
  State<BakeryLoginScreen> createState() => _BakeryLoginScreenState();
}

class _BakeryLoginScreenState extends State<BakeryLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nationalIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final savednationalId = prefs.getString('baker_id');
    final savedPassword = prefs.getString('bakery_password');
    final nationalId = _nationalIdController.text.trim();
    final password = _passwordController.text.trim();

    if (nationalId == savednationalId && password == savedPassword) {
      final bakeryProvider = Provider.of<BakeryProvider>(
        context,
        listen: false,
      );
      await bakeryProvider.loadBakeries();
      final current = bakeryProvider.getBakeryByOwner(nationalId);

      if (current != null) {
        bakeryProvider.loginBakery(
          nationalId: nationalId,
          location: current.location,
          bakeryName: current.bakeryName,
        );

        WelcomeSnackbar.show(context, current.bakeryName);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BakaryMainLayout()),
          (route) => false,
        );
      } else {
        ErrorSnackBar.show(context, 'لم يتم العثور على بيانات المخبز');
      }
    } else {
      ErrorSnackBar.show(context, 'بيانات الدخول غير صحيحة');
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ' تسجيل الدخول المخبز',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
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
                  if (val.length < 8)
                    return 'كلمة السر يجب أن تكون 8 أحرف على الأقل';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('تسجيل الدخول'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ليس لديك حساب؟',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.bakerySignUp);
                    },
                    child: Text(
                      'إنشاء حساب',
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
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
      textDirection: TextDirection.rtl,
    );
  }
}
