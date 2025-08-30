
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:txt_invite/src/models/profile.dart';
import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/ui/widgets/account_creation_steps/create_account_step.dart';
import 'package:txt_invite/src/ui/widgets/account_creation_steps/create_profile_step.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _pageController = PageController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  String? _userId;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (_formKey1.currentState!.validate()) {
      try {
        final user = await Api().auth.signUp(
          _emailController.text,
          _passwordController.text,
        );
        if (user == null) {
          throw Exception('User creation failed');
        }
        setState(() {
          _userId = user.id;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The password provided is too weak.')),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The account already exists for that email.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  Future<void> _saveUserProfile() async {
    if (_formKey2.currentState!.validate()) {
      try {
        final fcmToken = await Api().notifications.getDeviceToken(_userId!);
        if (fcmToken == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Device messaging token not found')),
          );
        }
        final profile = Profile(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          phoneNumber: _phoneNumberController.text,
          fcmToken: fcmToken,
          role: 'user',
        );
        await Api().auth.createProfile(_userId!, profile);
        GoRouter.of(context).go('/dashboard');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          CreateAccountStep(
            formKey: _formKey1,
            emailController: _emailController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            onNext: _createAccount,
          ),
          CreateProfileStep(
            formKey: _formKey2,
            firstNameController: _firstNameController,
            lastNameController: _lastNameController,
            phoneNumberController: _phoneNumberController,
            onCreate: _saveUserProfile,
          ),
        ],
      ),
    );
  }
}
