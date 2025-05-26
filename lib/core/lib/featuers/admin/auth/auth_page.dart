import 'package:car/core/components/snack.dart';
import 'package:car/featuers/home/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;
  String? errorMessage;

  Future<void> _authenticate() async {
    // Reset error message
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    // Validate inputs
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Please enter your email";
        isLoading = false;
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        errorMessage = "Please enter your password";
        isLoading = false;
      });
      return;
    }

    if (!_emailController.text.contains('@') ||
        !_emailController.text.contains('.')) {
      setState(() {
        errorMessage = "Please enter a valid email address";
        isLoading = false;
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        errorMessage = "Password must be at least 6 characters";
        isLoading = false;
      });
      return;
    }

    try {
      if (isLogin) {
        // Sign in with email and password
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Check if user is logged in
        if (FirebaseAuth.instance.currentUser != null) {
          Snack().success(context, "Logged in successfully");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (c) => HomePageView()));
        }
      } else {
        // Create user with email and password
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Check if user is created successfully
        if (FirebaseAuth.instance.currentUser != null) {
          Snack().success(context, "Account created successfully");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (c) => HomePageView()));
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No user found with this email";
          break;
        case 'wrong-password':
          message = "Wrong password provided";
          break;
        case 'email-already-in-use':
          message = "The email address is already in use";
          break;
        case 'invalid-email':
          message = "Invalid email address format";
          break;
        case 'weak-password':
          message = "The password is too weak";
          break;
        case 'operation-not-allowed':
          message = "Email/password accounts are not enabled";
          break;
        case 'user-disabled':
          message = "This user has been disabled";
          break;
        case 'too-many-requests':
          message = "Too many attempts. Try again later";
          break;
        case 'network-request-failed':
          message = "Network error. Check your connection";
          break;
        default:
          message = e.message ?? "An unknown error occurred";
      }
      setState(() {
        errorMessage = message;
      });
      Snack().error(context, message);
    } catch (e) {
      // Handle generic errors
      setState(() {
        errorMessage = e.toString();
      });
      Snack().error(context, e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 24, 23, 23),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 24, 23, 23),
          title: Text(isLogin ? "Login" : "Create Account",
              style: TextStyle(color: Colors.white)),
          elevation: 0,
        ),
        body: ListView(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.lock,
                      size: 50,
                      color: Colors.yellow,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Email Field
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      prefixIcon: Icon(Icons.email, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    style: TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey),
                    ),
                  ),

                  // Error Message
                  if (errorMessage != null) ...[
                    SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  SizedBox(height: 24),

                  // Login/Register Button
                  InkWell(
                    onTap: isLoading ? null : _authenticate,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.black)
                            : Text(
                                isLogin ? "Login" : "Create Account",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Toggle between Login and Register
                  TextButton(
                    onPressed: () => setState(() {
                      isLogin = !isLogin;
                      errorMessage = null;
                    }),
                    child: Text(
                      isLogin
                          ? "Don't have an account? Create one"
                          : "Already have an account? Login",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Development Mode Login

                  SizedBox(height: 40),

                  // Footer
                  Text(
                    "powered by  Amir Ashraf 2025",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ));
  }
}
