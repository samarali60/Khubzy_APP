import 'package:flutter/material.dart';
import 'package:khubzy/core/services/egypt_locations.dart';
import 'package:khubzy/core/widgets/error_snackbar.dart';
import 'package:khubzy/core/widgets/welcome_snackbar.dart';
import 'package:khubzy/models/citizen_model.dart';
import 'package:khubzy/screens/auth/provider/citizen_provider.dart';
import 'package:khubzy/screens/main/screens/main_layout.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_routes.dart';

class CitizenSignUpScreen extends StatefulWidget {
  const CitizenSignUpScreen({super.key});

  @override
  State<CitizenSignUpScreen> createState() => _CitizenSignUpScreenState();
}

class _CitizenSignUpScreenState extends State<CitizenSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController();

  String? _selectedGovernorate;
  String? _selectedCenter;
  List<String> centerOptions = [];

  bool _loading = false;

  @override
  void dispose() {
    _nationalIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGovernorate == null) {
      ErrorSnackBar.show(context, "اختر المحافظة");
      setState(() => _loading = false);
      return;
    }
    if (_selectedCenter == null) {
      ErrorSnackBar.show(context, "اختر المركز");
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);

    final citizenProvider = Provider.of<CitizenProvider>(
      context,
      listen: false,
    );
    await citizenProvider.loadCitizens();

    final nationalId = _nationalIdController.text.trim();
    final phone = _phoneController.text.trim();

    CitizenModel? matchedCitizen;
    try {
      matchedCitizen = citizenProvider.citizens.firstWhere(
        (citizen) => citizen.nationalId == nationalId && citizen.phone == phone,
      );
    } catch (e) {
      matchedCitizen = null;
    }

    if (matchedCitizen != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_type', 'citizen');
      await prefs.setString('user_phone', phone);
      await prefs.setString('user_password', _passwordController.text);
      await prefs.setString('user_village', _villageController.text);
      await prefs.setString('user_governorate', _selectedGovernorate ?? '');
      await prefs.setString('user_center', _selectedCenter ?? '');
      await prefs.setString('user_name', matchedCitizen.name);
      await prefs.setString('user_id', matchedCitizen.id);

      WelcomeSnackbar.show(context, matchedCitizen.name);

      Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => const MainLayout()),
         (route) => false,);
    } else {
      ErrorSnackBar.show(context, "بيانات المواطن غير صحيحة أو غير موجودة");
    setState(() => _loading = false);
    }


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
                  'إنشاء حساب خبزي',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nationalIdController,
                label: 'الرقم القومي',
                keyboardType: TextInputType.number,
                maxLength: 14,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'أدخل الرقم القومي';
                  }
                  if (!RegExp(r'^\d{14}$').hasMatch(value)) {
                    return 'الرقم القومي غير صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'أدخل البريد الإلكتروني';
                  }
                  if (!RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  ).hasMatch(value)) {
                    return 'البريد الإلكتروني غير صحيح';
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
                    return 'يجب أن تكون كلمة السر 8 أحرف على الأقل';
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
                    return 'رقم التليفون غير صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGovernorate,
                decoration: InputDecoration(
                  labelText: 'المحافظة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: locations.keys.map((governorate) {
                  return DropdownMenuItem(
                    value: governorate,
                    child: Text(governorate),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGovernorate = value;
                    centerOptions = locations[value]!;
                    _selectedCenter = null;
                  });
                },
                validator: (value) => value == null ? 'اختر المحافظة' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCenter,
                decoration: InputDecoration(
                  labelText: 'المركز',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: centerOptions.map((center) {
                  return DropdownMenuItem(value: center, child: Text(center));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCenter = value);
                },
                validator: (value) => value == null ? 'اختر المركز' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _villageController,
                keyboardType: TextInputType.text,
                label: 'القرية',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('تسجيل'),
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
                      Navigator.pushNamed(context, AppRoutes.citizenLogin);
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
    textDirection: TextDirection.rtl,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    validator: validator,
  );
}
