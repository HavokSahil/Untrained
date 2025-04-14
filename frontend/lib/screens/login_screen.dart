import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/data/services/api_services.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  final emailInputController = TextEditingController();
  final passwordInputController = TextEditingController();

  void onClickSignup() {
    Navigator.pushReplacementNamed(context, Constants.routeSignup);
  }

  void onClickSubmit() async {
    final email = emailInputController.text;
    final password = passwordInputController.text;

    final ApiResponse apiResponse = await ApiService.login(email, password);
    if (!mounted) return;
    if (apiResponse.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Log in successful"),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushNamed(context, Constants.routeHome, arguments: apiResponse.data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiResponse.error!),
          duration: Duration(seconds: 2),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    var textStyle = TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 32,
      fontWeight: FontWeight.bold
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Login",
              style: textStyle,
            ),
            const SizedBox(
              height: 32,
            ),
            Container(
              width: 300,
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFF272727),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  color: Colors.white
                ),
                cursorColor: Colors.white,
                textAlign: TextAlign.center,
                controller: emailInputController,
                decoration: InputDecoration(
                  hintText: "Email",
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 32,),
            Container(
              width: 300,
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFF272727),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextFormField(
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onClickSubmit(),
                style: TextStyle(
                  color: Colors.white,
                ),
                obscureText: true,
                cursorColor: Colors.white,
                textAlign: TextAlign.center,
                controller: passwordInputController,
                decoration: InputDecoration(
                  hintText: "Password",
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 32,),
            SizedBox(
              width: 300,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox( 
                    width: 120,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.black),
                        side: WidgetStateProperty.all(BorderSide(color: Colors.white, width: 2)),
                        
                      ),
                      onPressed: onClickSignup,
                      child: Text(
                        "Signup",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ),
                  ),
                  SizedBox( 
                    width: 120,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.white)
                      ),
                      onPressed: onClickSubmit,
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}