import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_services.dart';

class SignupScreen extends StatefulWidget {

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();

}

class _SignupScreenState extends State<SignupScreen> {

  final nameInputController = TextEditingController();
  final emailInputController = TextEditingController();
  final passwordInputController = TextEditingController();

  Role selectedRole = Role.user;

  void onClickLogin() {
    Navigator.pushReplacementNamed(context, Constants.routeLogin);
  }

  void onClickSubmit() async {
    final name = nameInputController.text;
    final email = emailInputController.text;
    final password = passwordInputController.text;
    final role = selectedRole.toString().toUpperCase().split('.')[1];
    final ApiResponse apiResponse = await ApiService.signup(name, email, password, role);
    if (!mounted) return;
    if (apiResponse.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User created successfully"),
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
  void dispose() {
    nameInputController.dispose();
    emailInputController.dispose();
    passwordInputController.dispose();
    super.dispose();
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
              "Signup",
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
                controller: nameInputController,
                decoration: InputDecoration(
                  hintText: "Name",
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
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
            Container(
              width: 300,
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFF272727),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(25),
              ),
              child: DropdownButtonFormField<Role>(
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                ),
                dropdownColor: const Color.fromARGB(255, 10, 10, 10),
                value: selectedRole,
                hint: const Text("Select Role"),
                items: Role.values.map((Role role) {
                  return DropdownMenuItem<Role>(
                    value: role,
                    child: Text(role.name),
                  );
                }).toList(),
                onChanged: (Role? newRole) {
                  setState(() {
                    selectedRole = newRole!;
                  });
                }
              )
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
                      onPressed: onClickLogin,
                      child: Text(
                        "Login",
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