import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wellness/admin/adminhome.dart';
import 'package:wellness/forgotpassword.dart';
import 'package:wellness/trainer/trainerhomepage.dart';
import 'package:wellness/user/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String email = '';
  String password = '';
  bool passwordVisible = false;
  bool isLoading = false;

  final String adminEmail = "shalu@2023.com";
  final String adminPassword = "shalu123";

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      _formKey.currentState!.save();

      try {
        if (email == adminEmail && password == adminPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Admin login successful")),
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminHomePage()));
          return;
        }

        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        DocumentSnapshot trainerDoc = await _firestore.collection('trainers').doc(userCredential.user!.uid).get();
        if (trainerDoc.exists && trainerDoc['approved'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No permission to login. Please contact admin.")),
          );
          return;
        }

        if (trainerDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Trainer login successful")));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TrainerHomePage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User login successful")));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Login error")));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
              child: Column(
                children: [
                  Text(
                    "Wellness",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Track. Transform. Thrive.",
                    style: TextStyle(color: Colors.white60, fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 40),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 15,
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: _inputDecoration("Email", Icons.email),
                              style: TextStyle(color: Colors.white),
                              validator: (value) => value!.isEmpty ? "Enter email" : null,
                              onSaved: (value) => email = value!,
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              obscureText: !passwordVisible,
                              decoration: _inputDecoration("Password", Icons.lock).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () => setState(() => passwordVisible = !passwordVisible),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                              validator: (value) => value!.isEmpty ? "Enter password" : null,
                              onSaved: (value) => password = value!,
                            ),
                            SizedBox(height: 30),
                            isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      minimumSize: Size(double.infinity, 50),
                                    ),
                                    child: Text("Login", style: TextStyle(fontSize: 18,color: Colors.white)),
                                  ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                                );
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white70, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.black54,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.deepPurple),
      ),
    );
  }
}
