import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MySQLAuthApp());
}

class MySQLAuthApp extends StatelessWidget {
  const MySQLAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BB88 LOGIN AUTH',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(247, 139, 159, 1)),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final username = TextEditingController();
  final pass = TextEditingController();
  bool isWelcome = true;
  bool loading = false;

  Future<void> submit() async {
    setState(() => loading = true);
    final url = isWelcome
        ? "http://localhost/flutterapi/getusers.php"
        : "http://localhost/flutterapi/insertusers.php";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username.text,
        "password": pass.text,
      }),
    );

    final data = jsonDecode(response.body);

    setState(() => loading = false);

    if (data["status"] == "success") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Dashboard(username: username.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"])),
      );
    }
  }

  @override

  bool isObscured = true;

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(239, 235, 236, 1) //ggboss i really cant get the bg image to work ahhahahahahahahahahhaahh whyyyyyyyyyyyyyyyyyyyy
        ),
        child: Center(
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 210, 210),
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 20,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Text(
                    isWelcome ? "Welcome!" : "Register now",
                    key: ValueKey(isWelcome),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(247, 139, 159, 1),
                    ),
                  ),
                const SizedBox(height: 20),
                TextField(
                  controller: username,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                    labelText: "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: pass,
                  obscureText: isObscured,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                    labelText: "Password",
                    suffixIcon: IconButton(
                            icon: isObscured
                                ? const Icon(Icons.visibility_off_outlined)
                                : const Icon(Icons.visibility_outlined),
                            onPressed: () {
                              setState(() {
                                isObscured = !isObscured;
                              });
                            },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                loading
                    ? const CircularProgressIndicator(color: Color.fromRGBO(247, 139, 159, 1))
                    : ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(247, 139, 159, 1),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isWelcome ? "Login" : "Register",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                TextButton(
                  onPressed: () => setState(() => isWelcome = !isWelcome),
                  child: Text(
                    isWelcome ? "Create new account" : "Already have an account?",
                    style: const TextStyle(color: Color.fromRGBO(223, 90, 115, 1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final String username;

  const Dashboard({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color.fromRGBO(247, 139, 159, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Center(
        child: Text(
          "Welcome $username 👋",
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

