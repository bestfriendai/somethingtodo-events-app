import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestAuthScreen extends StatefulWidget {
  const TestAuthScreen({super.key});

  @override
  State<TestAuthScreen> createState() => _TestAuthScreenState();
}

class _TestAuthScreenState extends State<TestAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _status = 'Ready to test';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testSignUp() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing sign up...';
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      setState(() {
        _status = 'Sign up successful! User: ${credential.user?.uid}';
      });
    } catch (e) {
      setState(() {
        _status = 'Sign up failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignIn() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing sign in...';
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _status = 'Sign in successful! User: ${credential.user?.uid}';
      });
    } catch (e) {
      setState(() {
        _status = 'Sign in failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignOut() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing sign out...';
    });

    try {
      await FirebaseAuth.instance.signOut();
      setState(() {
        _status = 'Sign out successful!';
      });
    } catch (e) {
      setState(() {
        _status = 'Sign out failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Auth Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Current User: ${FirebaseAuth.instance.currentUser?.email ?? 'None'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton(
                onPressed: _testSignUp,
                child: const Text('Test Sign Up'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _testSignIn,
                child: const Text('Test Sign In'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _testSignOut,
                child: const Text('Test Sign Out'),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Status: $_status',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/auth'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Back to Auth Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
