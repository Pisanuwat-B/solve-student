import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/auth.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/widgets/sizer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;

  AuthProvider? authprovider;
  @override
  Widget build(BuildContext context) {
    authprovider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: isLoading
          ? Center(
              child: Container(
                height: Sizer(context).h / 20,
                width: Sizer(context).h / 20,
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: Sizer(context).h / 20,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: Sizer(context).w / 0.5,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    height: Sizer(context).h / 50,
                  ),
                  Container(
                    width: Sizer(context).w / 1.1,
                    child: Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: Sizer(context).w / 1.1,
                    child: Text(
                      "Create Account to Contiue!",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Sizer(context).h / 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Container(
                      width: Sizer(context).w,
                      alignment: Alignment.center,
                      child: field("Name", Icons.account_box, _name),
                    ),
                  ),
                  Container(
                    width: Sizer(context).w,
                    alignment: Alignment.center,
                    child: field("email", Icons.account_box, _email),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Container(
                      width: Sizer(context).w,
                      alignment: Alignment.center,
                      child: field("password", Icons.lock, _password),
                    ),
                  ),
                  SizedBox(
                    height: Sizer(context).h / 20,
                  ),
                  customButton(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget customButton() {
    return GestureDetector(
      onTap: () {
        if (_name.text.isNotEmpty &&
            _email.text.isNotEmpty &&
            _password.text.isNotEmpty) {
          setState(() {
            isLoading = true;
          });

          authprovider!
              .createAccount(_name.text, _email.text, _password.text)
              .then(
            (user) {
              if (user != null) {
                setState(() {
                  isLoading = false;
                });
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Authenticate()));
                print("Account Created Sucessfull");
              } else {
                print("Login Failed");
                setState(() {
                  isLoading = false;
                });
              }
            },
          );
        } else {
          print("Please enter Fields");
        }
      },
      child: Container(
          height: Sizer(context).h / 14,
          width: Sizer(context).w / 1.2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: primaryColor,
          ),
          alignment: Alignment.center,
          child: Text(
            "Create Account",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )),
    );
  }

  Widget field(String hintText, IconData icon, TextEditingController cont) {
    return Container(
      height: Sizer(context).h / 14,
      width: Sizer(context).w / 1.1,
      child: TextField(
        controller: cont,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
