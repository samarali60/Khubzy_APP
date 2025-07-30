import 'package:flutter/material.dart';
import 'package:khubzy/core/widgets/error_snackbar.dart';
import 'package:khubzy/core/widgets/welcome_snackbar.dart';
import 'package:khubzy/screens/auth/provider/citizen_provider.dart';
import 'package:khubzy/screens/main/screens/main_layout.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';

class CitizenLoginScreen extends StatefulWidget {
  const CitizenLoginScreen({super.key});

  @override
  State<CitizenLoginScreen> createState() => _CitizenLoginScreenState();
}

class _CitizenLoginScreenState extends State<CitizenLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

@override
void initState() {
  super.initState();
  Provider.of<CitizenProvider>(context, listen: false).loadCitizens();
}
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('user_phone');
    final savedPassword = prefs.getString('user_password');
    final savedName = prefs.getString('user_name');

    final enteredPhone = _phoneController.text.trim();
    final enteredPassword = _passwordController.text;

    if (enteredPhone == savedPhone && enteredPassword == savedPassword) {
       await prefs.setBool('is_logged_in', true);
      WelcomeSnackbar.show(context, savedName ?? 'المستخدم');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
        (route) => false,
      );
      Provider.of<CitizenProvider>(context, listen: false)
    .setCurrentCitizenByPhone(enteredPhone);

    } else {
      ErrorSnackBar.show(context, 'رقم الهاتف أو كلمة السر غير صحيحة');
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'تسجيل دخول المواطن',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _phoneController,
                  label: 'رقم التليفون',
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'أدخل رقم التليفون';
                    if (!RegExp(r'^(010|011|012|015)[0-9]{8}$').hasMatch(val)) {
                      return 'رقم التليفون غير صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _passwordController,
                  label: 'كلمة السر',
                  obscure: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'أدخل كلمة السر';
                    }
                    if (value.length < 8) {
                      return 'كلمة السر قصيرة جداً';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('تسجيل الدخول'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب؟',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.citizenSignUp);
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
      ),
    );
  }
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
    ),
    validator: validator,
  );
}
