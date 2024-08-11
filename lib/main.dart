// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trippy_threads_admin/Employee/confirm_assign.dart';
import 'package:trippy_threads_admin/firebase_options.dart';
import 'package:trippy_threads_admin/home.dart';
import 'package:trippy_threads_admin/productview.dart';
import 'package:trippy_threads_admin/utilities.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Splash(),
    routes: {
      'view': (context) => ProductView(),
      'assignconfirm': (context) => AssignConfirm(),
    },
  ));
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    getloggedData().whenComplete(() {
      if (finalData == true) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Login(),
            ));
      }
    });
    super.initState();
  }

  bool? finalData;
  Future getloggedData() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var obtainedData = preferences.getBool('islogged');
    setState(() {
      finalData = obtainedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String errormessage = "";

  validateEmail(String emailid) {
    const pattern =
        r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-]{2,}$';
    final RegExp regExp = RegExp(pattern);
    if (emailid.isEmpty) {
      setState(() {
        errormessage = "Enter an email address";
      });
    } else if (!regExp.hasMatch(emailid)) {
      setState(() {
        errormessage = "Enter valid email id";
      });
    } else {
      setState(() {
        errormessage = "";
      });
    }
  }

  bool _obscureText = true;

  void togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future adminsignin() async {
    try {
      if (email.text == "trippythreadsadmin@gmail.com") {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.text, password: password.text);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Admin logged in successfully")));
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setBool('islogged', true);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ));
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Alert !"),
            content: Text("Admin's credentials are\n incorrect"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("ok"))
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Alert !"),
          content: Text("supplied credentials are\n incorrect"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("ok"))
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ADMIN LOGIN",
              style: GoogleFonts.aclonica(fontSize: 25),
            ),
            minheight,
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Enter email address",
                hintStyle: GoogleFonts.aclonica(),
                labelStyle: GoogleFonts.aclonica(),
                errorText: errormessage.isEmpty ? null : errormessage,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.black)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.black)),
              ),
              onChanged: validateEmail,
            ),
            minheight,
            TextField(
              controller: password,
              obscureText: _obscureText,
              keyboardType: TextInputType.visiblePassword,
              cursorColor: Colors.blueGrey,
              decoration: InputDecoration(
                  focusColor: Colors.blueGrey,
                  labelText: "Password",
                  hintText: "********",
                  hintStyle: GoogleFonts.aclonica(),
                  labelStyle: GoogleFonts.aclonica(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.black)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.black)),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: togglePasswordVisibility,
                  )),
            ),
            minheight,
            minheight,
            ElevatedButton(
              onPressed: () {
                validateEmail(email.text);
                if (errormessage.isEmpty) {
                  adminsignin();
                }
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                  minimumSize: MaterialStateProperty.all(Size(150, 40))),
              child: Text(
                "Sign In",
                style: GoogleFonts.aclonica(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
