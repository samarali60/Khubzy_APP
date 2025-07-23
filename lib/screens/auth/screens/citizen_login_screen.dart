import 'package:flutter/material.dart';
 import 'dart:math';
import 'package:khubzy/core/widgets/welcome_snackbar.dart';
import 'package:khubzy/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CitizenLoginScreen extends StatefulWidget {
  const CitizenLoginScreen({super.key});
  @override
  State<CitizenLoginScreen> createState() => _CitizenLoginScreenState();
}

class _CitizenLoginScreenState extends State<CitizenLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _cardIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  // 🌀 متغير لتحميل البيانات
bool _loading = false;

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);

  // simulate login delay
  await Future.delayed(const Duration(seconds: 1));

  final prefs = await SharedPreferences.getInstance();

  // 🆔 توليد ID مميز للمواطن (مثلاً من timestamp)
  final userId = DateTime.now().millisecondsSinceEpoch.toString();

  // 👨‍👩‍👧‍👦 عدد أفراد الأسرة (1 - 5)
  final familyMembers = Random().nextInt(5) + 1;

  // 🍞 عدد أرغفة العيش = 5 * عدد الأفراد
  final breadCount = familyMembers * 5 * 30;
 
  final max_bread =  familyMembers * 5;
  // 💾 تخزين البيانات
  await prefs.setBool('is_logged_in', true);
  await prefs.setString('user_id', userId);
  await prefs.setString('user_type', 'citizen');
  await prefs.setString('user_name', _nameController.text);
  await prefs.setString('user_national_id', _nationalIdController.text);
  await prefs.setString('user_card_id', _cardIdController.text);
  await prefs.setString('user_phone', _phoneController.text);
  await prefs.setString('user_password', _passwordController.text);
  await prefs.setInt('family_$userId', familyMembers);
  await prefs.setInt('bread_$userId', breadCount);
  await prefs.setInt('remaining_bread', breadCount);
  await prefs.setInt('max_bread', max_bread);

  // ✅ عرض Snackbar بالترحيب
  WelcomeSnackbar.show(context, _nameController.text);

  // 🚀 الانتقال إلى الصفحة الرئيسية
  Navigator.pushReplacementNamed(
    context,
    AppRoutes.main,
    arguments: {'user_type': 'citizen'},
  );

  setState(() => _loading = false);
}

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _cardIdController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   // final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("تسجيل الدخول (مواطن)"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'الاسم بالكامل',
                validator: (val) => val!.isEmpty ? 'من فضلك أدخل الاسم' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nationalIdController,
                label: 'الرقم القومي',
                keyboardType: TextInputType.number,
                maxLength: 14,
                validator: (val) =>
                    val!.length != 14 ? 'يجب أن يكون 14 رقم' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _cardIdController,
                label: 'رقم البطاقة',
                keyboardType: TextInputType.number,
                maxLength: 12,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'أدخل رقم البطاقة';
                  if (val.length != 12) {
                    return 'رقم البطاقة يجب أن يكون  12 أرقام';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
                    return 'رقم البطاقة غير صالح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _passwordController,
                label: 'الرقم السري',
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (val) =>
                    val!.length != 4 ? 'يجب أن يكون 4 رقم' : null,
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

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('تسجيل الدخول'),
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
}
